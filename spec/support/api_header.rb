# frozen_string_literal: true

module ApiHeader
  def set_header
    header 'Accept', 'application/vnd.providesk; version=1'
    header 'Content-Type', 'application/json'
  end
end
