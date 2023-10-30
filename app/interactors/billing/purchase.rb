class Purchase < ApplicationInteractor
  integer :product_id,
          :amount

  string :address

  object :current_user, class: User

  validates :product_id, 
            :amount,
            :current_user,
            :address,
    presence: true

  def execute
    ActiveRecord::Base.transaction do
      product = yield find_product
      yield make_payment
      product_access = yield grant_access(product)
      yield notify
      yield deliver(product.weight)
    end
  end

  private

  def find_product
    product = Product.find(product_id)
    product.present? ? Success(product) : Failure(:find_error)
  end

  def make_payment
    payment_result = CloudPayment.proccess(
      user_uid: current_user.cloud_payments_uid,
      amount_cents: amount * 100,
      currency: 'RUB'
    )

    payment_result.succes? ? Success(payment_result) : Failure(:payment_error)
  end

  def grant_access(prodcut)
    product_access = ProductAccess.create(user: current_user, product:)
    product_access.present? ? Success(payment_result) : Failure(:access_error)
  end

  def notify
    OrderMailer.product_access_email(product_access).deliver_later
    Success(:ok)
  end

  def deliver(weight)
    delivery = Sdek.setup_delivery(address:, person: current_user, weight:)
    delivery[:result] == 'success' ? Success(:ok) : Failure(:delivery_error)
  end
end
