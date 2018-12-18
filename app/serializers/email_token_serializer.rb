# frozen_string_literal: true

class EmailTokenSerializer < TokenSerializer
  attribute :addresses, predicate: NS::ARGU[:emailAddresses], datatype: NS::XSD[:string], if: :never
  attribute :creator, predicate: NS::SCHEMA[:creator], if: :never

  attribute :send_mail, predicate: NS::ARGU[:sendMail], datatype: NS::XSD[:boolean], if: :service_scope?
end
