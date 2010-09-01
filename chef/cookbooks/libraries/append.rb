module Append
  def append_if_no_such_line(filename, line)
    execute "cat '#{line}' >> #{filename}" do
      not_if { "egrep -q '^#{line}$' #{filename}" }
    end
  end
end
