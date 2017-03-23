module MessageTrain
  # Conversation model
  class Conversation < ActiveRecord::Base
    has_many :messages, foreign_key: :message_train_conversation_id
    has_many :ignores, foreign_key: :message_train_conversation_id
    has_many :receipts, through: :messages
    has_many :attachments, through: :messages

    # Scopes
    default_scope { order(updated_at: :desc) }
    scope :by_ignored, ->(p, flag) { flag ? ignored(p) : unignored(p) }

    scope :ignored, ->(participant) { where(id: ignored_ids_for(participant)) }

    scope :unignored, (lambda do |participant|
      where.not(id: ignored_ids_for(participant))
    end)

    scope :with_drafts_by, (lambda do |participant|
      messages.drafts.with_receipts_by(participant).conversations
    end)

    scope :with_ready_for, (lambda do |participant|
      messages.ready.with_receipts_for(participant).conversations
    end)

    scope :with_messages_for, (lambda do |participant|
      messages.with_receipts_for(participant).conversations
    end)

    scope :without_trashed_for, (lambda do |participant|
      where.not(id: messages.with_trashed_for(participant).conversations)
    end)

    scope :without_deleted_for, (lambda do |participant|
      where.not(id: messages.with_deleted_for(participant).conversations)
    end)

    scope :with_messages_through, (lambda do |participant|
      messages.with_receipts_through(participant).conversations
    end)

    scope :filter_by_receipt_method, (lambda do |receipt_method, participant|
      messages.receipts.send(receipt_method, participant).conversations
    end)

    scope :filter_by_division, (lambda do |division|
      found = if division == :drafts
                with_drafts_by(participant)
              else
                with_ready_for(participant)
              end
      found.by_ignored(participant, division == :ignored)
    end)

    scope :filter_by_preposition, (lambda do |prep, *args|
      messages.filter_by_receipt_method(prep, *args).conversations
    end)

    scope :filter_by_status_and_preposition, (lambda do |status, prep, *args|
      case status
      when :ready, :drafts
        messages.send(status)
                .filter_by_receipt_method(prep, *args)
                .conversations
      when :messages
        filter_by_preposition(prep, *args)
      else
        filter_by_receipt_method("#{status}_#{prep}", *args)
      end
    end)

    def self.ignored_ids_for(participant)
      MessageTrain::Ignore.find_all_by_participant(participant)
                          .pluck(:message_train_conversation_id)
    end

    def self.messages
      MessageTrain::Message.for_conversations(ids)
    end

    def default_recipients_for(sender)
      default_recipients = messages.with_receipts_for(sender).map do |c|
        c.receipts.map(&:recipient)
      end.flatten.uniq
      default_recipients.delete(sender)
      default_recipients
    end

    def new_reply(args)
      args[:reply_recipients] = default_recipients_for(args.delete(:box).parent)
      args[:subject] = "Re: #{subject}"
      args[:body] = "<blockquote>#{messages.last.body}</blockquote><p></p>"
      messages.build(args)
    end

    def participant_ignore(participant)
      ignores.first_or_create!(participant: participant)
    end

    def participant_unignore(participant)
      ignores.where(participant: participant).destroy_all
    end

    def participant_ignored?(participant)
      ignores.empty? ? false : ignores.find_all_by_participant(participant).any?
    end

    def mark(mark, participant)
      messages.mark(mark, participant)
    end

    def method_missing(method_sym, *args, &block)
      string = method_sym.to_s
      return super unless string =~ /\Aincludes_(.*)_(by|to|for|through)\?\z/
      includes_matches_with_preposition?(
        Regexp.last_match[1].to_sym, Regexp.last_match[2].to_sym, *args
      )
    end

    def includes_matches_with_preposition?(flag, prep, *args)
      unless [:ready, :drafts].include? flag
        return includes_matching_receipts?("#{flag}_#{prep}".to_sym, *args)
      end
      return includes_matching_messages_by?(flag, *args) if prep == 'by'
      includes_matching_messages_with_prep?(flag, prep, *args)
    end

    def includes_matching_receipts?(match_method_sym, *args)
      receipts.send(match_method_sym, *args).any?
    end

    def respond_to_missing?(method_sym, include_private = false)
      method_sym.to_s =~ /\Aincludes_.*_(by|to|for|through)\?\z/ || super
    end

    def self.method_missing(method_sym, *args, &block)
      return super unless method_sym.to_s =~ /^with_(.*)_(by|to|for|through)$/
      status = Regexp.last_match[1].to_sym
      preposition = Regexp.last_match[2].to_sym
      filter_by_status_and_preposition(status, preposition, *args)
    end

    def self.respond_to_missing?(method_sym, include_private = false)
      method_sym.to_s =~ /^with_(.*)_(by|to|for|through)$/ || super
    end

    protected

    def includes_matching_messages_by?(flag, *args)
      messages.send(flag).by(*args).any?
    end

    def includes_matching_messages_with_prep?(flag, preposition, *args)
      messages.send(flag).receipts.flagged(preposition, *args).any?
    end
  end
end
