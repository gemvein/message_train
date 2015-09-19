module Wysihtml5Helper
  def fill_in_html label, options
    page.execute_script <<-JAVASCRIPT
      var id = $("label:contains(#{label})").attr("for");
      $("#" + id).data("wysihtml5").editor.setValue("#{options[:with]}");
    JAVASCRIPT
  end
end