shared_examples_for 'a successful page' do |options = {}|
  context 'responds successfully' do
    subject { response }
    it { should be_success }
  end
  if options[:which_renders].present?
    it_behaves_like 'a page rendering a template', options[:which_renders]
  end
end
shared_examples_for 'a page rendering a template' do |template|
  context "renders the #{template} template" do
    subject { response }
    it { should render_template(template) }
  end
end
shared_examples_for 'an error response' do |http_status|
  context "issues error response code #{http_status}" do
    subject { response }
    it { should have_http_status(http_status) }
  end
end
shared_examples_for 'a redirect to' do |path|
  context "redirects to #{path}" do
    subject { response }
    it { should redirect_to path_to_url(path) }
  end
end
shared_examples_for 'a redirect matching' do |path_expression|
  context "redirects matching #{path_expression}" do
    subject { response.location }
    it { should match path_expression }
  end
end
shared_examples_for 'a redirect to sign in' do
  it_behaves_like 'a redirect to', '/users/sign_in'
end
shared_examples_for 'an error response with message' do |message|
  it_behaves_like 'an error response', :forbidden
  context 'sets failure message' do
    subject { flash[:error] }
    it { should eq message }
  end
end
shared_examples_for 'a 404 Not Found error' do
  it_behaves_like 'an error response', :not_found
  it_behaves_like 'a page rendering a template', '404'
end
shared_examples_for 'a page with a message' do |options|
  it_behaves_like 'a successful page'
  options.each do |key, value|
    context "sets #{key.to_s} message" do
      subject { flash[key] }
      it { should eq value }
    end
  end
end
shared_examples_for 'a page with a message matching' do |options|
  it_behaves_like 'a successful page'
  options.each do |key, value|
    context "sets #{key.to_s} message" do
      subject { flash[key] }
      it { should match value }
    end
  end
end
shared_examples_for 'a page with an error message' do |message|
  it_behaves_like 'a page with a message', error: message
end
shared_examples_for 'a page with an alert message' do |message|
  it_behaves_like 'a page with a message', alert: message
end
shared_examples_for 'a page with a notice message' do |message|
  it_behaves_like 'a page with a message', notice: message
end
shared_examples_for 'a page with an error message matching' do |message|
  it_behaves_like 'a page with a message matching', error: message
end
shared_examples_for 'a 403 Forbidden error' do
  it_should_behave_like 'an error response with message', 'You are not authorized to access this page.'
end
shared_examples_for 'a redirect with error' do |path, message|
  it_behaves_like 'a redirect to', path
  context 'sets error' do
    subject { flash[:error] }
    it { should eq message }
  end
end
shared_examples_for 'a redirect with notice' do |path, message|
  it_behaves_like 'a redirect to', path
  context 'sets notice' do
    subject { flash[:notice] }
    it { should eq message }
  end
end
shared_examples_for 'a redirect with alert' do |path, message|
  it_behaves_like 'a redirect to', path
  context 'sets alert' do
    subject { flash[:alert] }
    it { should eq message }
  end
end
shared_examples_for 'a response without error' do
  context 'sets no errors' do
    subject { flash[:error] }
    it { should be nil }
  end
end