module RequestHelper
  def price_format(amount)
    return "£#{amount/100}.#{amount % 100}"
  end
end
