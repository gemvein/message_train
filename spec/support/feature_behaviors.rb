shared_examples_for 'an authenticated section' do |path|
  describe 'requires login' do
    before do
      visit path
    end
    it_behaves_like(
      'a bootstrap page with an alert',
      'danger',
      'You must sign in or sign up to continue.'
    )
    context 'displays a login form' do
      subject { page }
      it { is_expected.to have_selector 'form.new_user input#user_email' }
      it { is_expected.to have_selector 'form.new_user input#user_password' }
    end
  end
end

shared_examples_for 'a bootstrap page' do |options = {}|
  include ERB::Util
  context 'displays a page with bootstrap elements' do
    subject { page }
    if options[:title].present?
      it { is_expected.to have_title html_escape(options[:title]) }
      it { is_expected.to have_xpath '//h2', text: options[:title] }
    end
    it do
      expect(page).to(
        have_selector(
          '.top-navigation .site-brand',
          text: MessageTrain.configuration.site_name
        )
      )
    end
  end
end

shared_examples_for(
  'a bootstrap page with a dropdown navigation list'
) do |options|
  if options[:text]
    it do
      expect(page).to have_selector 'details.message-train-dropdown-nav-item summary', text: options[:text]
    end
  else
    it { is_expected.to have_selector 'details.message-train-dropdown-nav-item summary' }
  end
end

shared_examples_for 'a bootstrap page with an alert' do |type, text|
  subject { page }
  it { is_expected.to have_selector "#alert_area .alert.#{type}", text: text }
end

shared_examples_for 'a bootstrap page without an alert' do |type|
  subject { page }
  it { is_expected.not_to have_selector "#alert_area .alert.#{type}" }
end

shared_examples_for(
  'a bootstrap page listing a collection of items'
) do |object, options = {}|
  options[:minimum] ||= 1
  options[:plural_title] ||= object.model_name.human.pluralize(2)
  options[:plural_name] ||= object.table_name
  collection_css_id = options[:plural_name].tr('_', '-')
  member_css_class = options[:plural_name].singularize
  it_behaves_like 'a bootstrap page', title: options[:plural_title].titlecase
  context "displays a list of ##{collection_css_id} in .#{member_css_class}" do
    subject { page }
    it do
      expect(page).to(
        have_css(
          "##{collection_css_id} .#{member_css_class}",
          minimum: options[:minimum]
        )
      )
    end
  end
end

shared_examples_for(
  'a bootstrap page showing an item'
) do |object, title, options = {}|
  options[:css_id] ||= object.table_name.singularize
  it_behaves_like 'a bootstrap page', title: title
  context "displays an item at ##{options[:css_id]}" do
    subject { page }
    it { is_expected.to have_css("##{options[:css_id]}") }
  end
end

shared_examples_for 'a bootstrap form with errors' do |error_fields|
  subject { page }
  error_fields.each do |field|
    it_behaves_like(
      'a bootstrap page with an alert',
      'danger',
      "#{field.to_s.humanize} can't be blank"
    )
    context 'shows which field has errors' do
      subject { page }
      it { is_expected.to have_css('.field_with_errors', text: field.to_s.humanize) }
    end
  end
end
