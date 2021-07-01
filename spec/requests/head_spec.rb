# frozen_string_literal: true

require 'spec_helper'

describe 'Head' do
  let(:token) { create(:token) }

  before do
    as_guest
  end

  it 'handles a valid request' do
    head "/argu/tokens/#{token.secret}", headers: service_headers(accept: :nq)
    assert_response 200
  end

  it 'handles a wrong iri prefix' do
    find_tenant_mock("#{ENV['HOSTNAME']}\/wrong\/tokens.*", shortnames: %w[argu wrong])
    head "/wrong/tokens/#{token.secret}", headers: service_headers(accept: :nq)
    assert_redirected_to resource_iri(token).to_s.sub('http', 'https')
  end
end
