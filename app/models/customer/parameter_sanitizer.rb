class Customer::ParameterSanitizer < Devise::ParameterSanitizer
  def initialize(*)
    super
    permit(:sign_up, keys: [ :name ])
    permit(:account_update, keys: [ :name ])
  end
end
