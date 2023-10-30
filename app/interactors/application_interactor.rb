class ApplicationInteractor
  include Dry::Monads::Do
  include Dry::Monads::Result::Mixin

  def execute  
    raise NotImplementedError
  end
end
