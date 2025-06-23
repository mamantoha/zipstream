module Zipstream
  extend self

  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  GIT_SHA =
    {% if flag?(:windows)%}
      {{ `powershell -Command "try { git rev-parse --short HEAD } catch { $null }"`.chomp.stringify }}.presence
    {% else %}
      {{ `(git rev-parse --short HEAD || true) 2>/dev/null`.chomp.stringify }}.presence
    {% end %}

  def version
    if GIT_SHA
      "%s [%s]" % {VERSION, GIT_SHA}
    else
      VERSION
    end
  end
end
