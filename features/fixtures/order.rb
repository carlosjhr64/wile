# frozen_string_literal: true

# :reek:IrresponsibleModule :reek:UncommunicativeMethodName
class OrderTest
  def m7
    m4
  end

  def m5 = :ok

  def m2
    m3
  end

  def m1
    m2
  end

  def m8
    m4
    m2
  end

  def m3 = :ok

  def m6 = :ok

  def m4 = :ok
end
