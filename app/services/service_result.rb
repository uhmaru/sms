# typed: strict

class ServiceResult
  extend T::Sig

  sig { returns(T.nilable(T.anything)) }
  attr_reader :data

  sig { returns(T::Array[String]) }
  attr_reader :errors

  sig { params(data: T.nilable(T.anything)).returns(ServiceResult) }
  def self.success(data = nil)
    new(success: true, data: data)
  end

  sig { params(errors: T.any(T::Array[String], String)).returns(ServiceResult) }
  def self.failure(errors)
    new(success: false, errors: Array(errors))
  end

  sig do
    params(
      success: T::Boolean,
      data: T.untyped,
      errors: T::Array[String]
    ).void
  end
  def initialize(success:, data: nil, errors: [])
    @success = success
    @data = data
    @errors = errors

    T.let(@success, T::Boolean)
    T.let(@data, T.untyped)
    T.let(@errors, T::Array[String])
  end

  sig { returns(T::Boolean) }
  def success?
    @success
  end

  sig { returns(T::Boolean) }
  def failure?
    !@success
  end
end
