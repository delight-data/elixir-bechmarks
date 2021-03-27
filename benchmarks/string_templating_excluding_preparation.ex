simple_template = File.read!("inputs/template_simple.txt")
variables = [:loul]
nb_bindings = 10_000

bindings = TemplatingBenchmarks.create_bindings(nb_bindings, variables)

## First template
IO.inspect("Running benchmark for a small template with 1 variable.")

# Creating the prepared templates
prepared1 = TemplatingBenchmarks.base_templating_create(simple_template)
prepared2 = TemplatingBenchmarks.eex_templating_create(simple_template)
prepared3 = TemplatingBenchmarks.manual_templating_create(simple_template)
prepared4 = TemplatingBenchmarks.eex_eval_string_templating_create(simple_template)
prepared5 = TemplatingBenchmarks.eex_compiled_templating_create(simple_template)

# Running them once to check that results match
result1 = TemplatingBenchmarks.base_templating_run(prepared1, bindings)
result2 = TemplatingBenchmarks.eex_templating_run(prepared2, bindings)
result3 = TemplatingBenchmarks.manual_templating_run(prepared3, bindings)
result4 = TemplatingBenchmarks.eex_eval_string_templating_run(prepared4, bindings)
result5 = TemplatingBenchmarks.eex_compiled_templating_run(prepared5, bindings)

if result1 != result2 or result1 != result3 or result1 != result4 or result1 != result5 do
  IO.inspect(result1 == result2)
  IO.inspect(result1 == result3)
  IO.inspect(result1 == result4)
  IO.inspect(result1 == result5)
  raise "One of the outputs is not equal to the others"
end


Benchee.run(%{
  "base" => fn -> TemplatingBenchmarks.base_templating_run(prepared1, bindings) end,
  "eex" => fn -> TemplatingBenchmarks.eex_templating_run(prepared2, bindings) end,
  "manual" => fn -> TemplatingBenchmarks.manual_templating_run(prepared3, bindings) end,
  "eex_eval_string" => fn -> TemplatingBenchmarks.eex_eval_string_templating_run(prepared4, bindings) end,
  "eex_compiled" => fn -> TemplatingBenchmarks.eex_compiled_templating_run(prepared5, bindings) end
})


## Second template
IO.inspect("Running benchmark for a large template with 4 variables.")
long_template = File.read!("inputs/template_long.txt")

variables = [:var1, :var2, :var3, :var4]
nb_bindings = 10_000

bindings = TemplatingBenchmarks.create_bindings(nb_bindings, variables)

# Creating the prepared templates
prepared1 = TemplatingBenchmarks.base_templating_create(long_template)
prepared2 = TemplatingBenchmarks.eex_templating_create(long_template)
prepared3 = TemplatingBenchmarks.manual_templating_create(long_template)
prepared4 = TemplatingBenchmarks.eex_eval_string_templating_create(long_template)
prepared5 = TemplatingBenchmarks.eex_compiled_templating_create(long_template)

Benchee.run(%{
  "base" => fn -> TemplatingBenchmarks.base_templating_run(prepared1, bindings) end,
  "eex" => fn -> TemplatingBenchmarks.eex_templating_run(prepared2, bindings) end,
  "manual" => fn -> TemplatingBenchmarks.manual_templating_run(prepared3, bindings) end,
  "eex_eval_string" => fn -> TemplatingBenchmarks.eex_eval_string_templating_run(prepared4, bindings) end,
  "eex_compiled" => fn -> TemplatingBenchmarks.eex_compiled_templating_run(prepared5, bindings) end
})
