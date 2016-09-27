# frozen_string_literal: true
module TestMocks
  def current_user_guest_mock
    stub_request(:get, "#{host_name}/spi/current_user")
      .to_return(
        status: 401,
        headers: {'Content-Type' => 'application/json'}
      )
  end

  def current_user_user_mock(id = 1)
    stub_request(:get, "#{host_name}/spi/current_user")
      .to_return(
        status: 200,
        headers: {'Content-Type' => 'application/json'},
        body: {
          data: {
            id: id,
            type: 'users',
            attributes: {
              display_name: "User#{id}",
              url: "user#{id}",
              email: "user#{id}@email.com"
            }
          }
        }.to_json
      )
  end

  def create_membership_mock(opts = {})
    stub_request(:post, "#{host_name}/g/#{opts[:group_id]}/memberships")
      .with(
        body: {
          shortname: "user#{opts[:user_id]}",
          token: opts[:secret]
        }
      ).to_return(status: opts[:response] || 201, body: '')
  end

  def authorized_mock(type, id, action)
    stub_request(
      :get,
      "#{host_name}/spi/authorize?authorize_action=#{action}&resource_id=#{id}&resource_type=#{type}"
    ).to_return(status: 200)
  end

  def unauthorized_mock(type, id, action)
    url = if id.present?
            "#{host_name}/spi/authorize?authorize_action=#{action}&resource_id=#{id}&resource_type=#{type}"
          else
            "#{host_name}/spi/authorize?authorize_action=#{action}&resource_type=#{type}"
          end
    stub_request(:get, url).to_return(status: 403)
  end

  private

  def host_name
    Rails.application.config.host_name
  end
end
