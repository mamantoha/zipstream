module Zipstream
  extend self

  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
  GIT_SHA = {{ `(git rev-parse --short HEAD || true) 2>/dev/null`.chomp.stringify }}.presence

  def version
    if GIT_SHA
      "%s [%s]" % {VERSION, GIT_SHA}
    else
      VERSION
    end
  end
end
