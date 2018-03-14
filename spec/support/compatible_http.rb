# NOTE: this is needed to keep our test suite compatible with both Rails 4 + 5
# See https://github.com/nebulab/cangaroo/pull/60#issue-175032794
def compatible_http(method, path, args)
  case Rails::VERSION::MAJOR
  when 4 then self.send(method, path, args[:params], args[:headers])
  when 5 then self.send(method, path, args)
  end
end
