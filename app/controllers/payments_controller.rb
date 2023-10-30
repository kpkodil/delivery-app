class PaymentsController < ApplicationController
  def create
    purchase_result = Billing::Purchase.run!(purchase_params)

    if purchase_result.success?
      redirect_to :successful_payment_path
    else
      redirect_to :failed_payment_path, note: purchase_result.error_message
    end
  end

  private

  def purchase_params
    params.permit(:product_id, :amount)
          .merge(current_user: current_user)
  end
end
