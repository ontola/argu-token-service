# frozen_string_literal: true

class EmailTokenSerializer < TokenSerializer
  attribute :addresses, predicate: NS::ARGU[:emailAddresses], datatype: NS::XSD[:string]
  attribute :send_mail, predicate: NS::ARGU[:sendMail], datatype: NS::XSD[:boolean]
  attribute :creator, predicate: NS::SCHEMA[:creator]

  def addresses; end

  def creator; end

  def send_mail; end
end
