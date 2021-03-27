IO.inspect("Running benchmark for a small template with 1 variable.")
simple_template = File.read!("inputs/template_simple.txt")
variables = [:loul]
nb_bindings = 10_000

bindings = TemplatingBenchmarks.create_bindings(nb_bindings, variables)

result1 = TemplatingBenchmarks.base_templating(simple_template, bindings)
result2 = TemplatingBenchmarks.eex_templating(simple_template, bindings)
result3 = TemplatingBenchmarks.manual_templating(simple_template, bindings)
result4 = TemplatingBenchmarks.eex_eval_string_templating(simple_template, bindings)
result5 = TemplatingBenchmarks.eex_compiled_templating(simple_template, bindings)

if result1 != result2 or result1 != result3 or result1 != result4 or result1 != result5 do
  IO.inspect(result1 == result2)
  IO.inspect(result1 == result3)
  IO.inspect(result1 == result4)
  IO.inspect(result1 == result5)
  raise "One of the outputs is not equal to the others"
end


Benchee.run(%{
  "base" => fn -> TemplatingBenchmarks.base_templating(simple_template, bindings) end,
  "eex" => fn -> TemplatingBenchmarks.eex_templating(simple_template, bindings) end,
  "eex_compiled" => fn -> TemplatingBenchmarks.eex_compiled_templating(simple_template, bindings) end,
  "eex_eval_string" => fn -> TemplatingBenchmarks.eex_eval_string_templating(simple_template, bindings) end,
  "manual" => fn -> TemplatingBenchmarks.manual_templating(simple_template, bindings) end
})

IO.inspect("Running benchmark for a large template with 4 variables.")
long_template = File.read!("inputs/template_long.txt")

variables = [:var1, :var2, :var3, :var4]
nb_bindings = 10_000

bindings = TemplatingBenchmarks.create_bindings(nb_bindings, variables)

Benchee.run(%{
  "base" => fn -> TemplatingBenchmarks.base_templating(long_template, bindings) end,
  "eex" => fn -> TemplatingBenchmarks.eex_templating(long_template, bindings) end,
  "eex_compiled" => fn -> TemplatingBenchmarks.eex_compiled_templating(long_template, bindings) end,
  "eex_eval_string" => fn -> TemplatingBenchmarks.eex_eval_string_templating(long_template, bindings) end,
  "manual" => fn -> TemplatingBenchmarks.manual_templating(long_template, bindings) end
})
