defmodule TemplatingBenchmarks do
  def base_templating_create(template) do
    map_regex =
      template
      |> variable_names_from_template()
      |> Enum.reduce(%{}, fn variable_name, acc ->
        {:ok, regex} = Regex.compile("<%= #{variable_name} %>")
        Map.put(acc, variable_name, regex)
      end)

    {template, map_regex}
  end

  def base_templating_run({template, map_regex}, bindings) do
    Enum.map(bindings, fn binding ->
      Enum.reduce(binding, template, fn {variable_name, variable_value}, acc ->
        map_regex
        |> Map.get(variable_name)
        |> Regex.replace(acc, variable_value)
      end)
    end)
  end

  def base_templating(template, bindings) do
    template
    |> base_templating_create()
    |> base_templating_run(bindings)
  end

  def eex_templating_create(template) do
    EEx.compile_string(template)
  end

  def eex_templating_run(compiled_template, bindings) do
    Enum.map(bindings, fn binding ->
      {result, _} = Code.eval_quoted(compiled_template, binding)
      result
    end)
  end

  def eex_templating(template, bindings) do
    template
    |> eex_templating_create
    |> eex_templating_run(bindings)
  end

  def eex_compiled_templating_create(template) do
    variable_names = variable_names_from_template(template)

    module_body =
      quote bind_quoted: [template: template, variable_names: variable_names] do
        require EEx
        EEx.function_from_string(:def, :example, template, variable_names)
      end

    module_name = String.to_atom("#{Enum.random(0..1_000_000)}")
    Module.create(module_name, module_body, Macro.Env.location(__ENV__))
    module_name
  end

  def eex_compiled_templating_run(compiled_template, bindings) do
    Enum.map(bindings, fn binding ->
      apply(compiled_template, :example, Keyword.values(binding))
    end)
  end

  def eex_compiled_templating(template, bindings) do
    template
    |> eex_compiled_templating_create()
    |> eex_compiled_templating_run(bindings)
  end

  @doc "This function is only here to be coherent with the others"
  def eex_eval_string_templating_create(template), do: template

  def eex_eval_string_templating_run(template, bindings) do
    Enum.map(bindings, fn binding ->
      EEx.eval_string(template, binding)
    end)
  end

  def eex_eval_string_templating(template, bindings),
    do: eex_eval_string_templating_run(template, bindings)

  def manual_templating_create(template) do
    parts =
      template
      |> String.split("%>")

    variables =
      parts
      |> Enum.map(fn part ->
        [_ | variable] = String.split(part, "<%=")
        variable
      end)
      |> Enum.reject(fn variable -> variable == [] end)
      |> Enum.map(fn [variable] -> variable |> String.trim() |> String.to_atom() end)

    [first_part | remaining_parts] =
      Enum.map(parts, fn part ->
        [filtered_part | _] = String.split(part, "<%=")
        filtered_part
      end)

    {first_part, Enum.zip(remaining_parts, variables)}
  end

  def manual_templating_run(compiled_template, bindings) do
    Enum.map(bindings, fn binding ->
      fill_template(compiled_template, binding)
    end)
  end

  def manual_templating(template, bindings) do
    template
    |> manual_templating_create
    |> manual_templating_run(bindings)
  end

  defp fill_template({first_part, variable_with_template}, binding) do
    map_binding = Enum.reduce(binding, %{}, fn {key, value}, acc -> Map.put(acc, key, value) end)

    Enum.reduce(variable_with_template, first_part, fn {part, variable_name}, acc ->
      acc <> Map.get(map_binding, variable_name) <> part
    end)
  end

  @doc "Utility function to create keyword lists in the tests"
  def create_bindings(nb_bindings, variables) do
    Enum.map(0..nb_bindings, fn iteration ->
      Enum.map(variables, fn variable_name -> {variable_name, "#{variable_name}-#{iteration}"} end)
    end)
  end

  defp variable_names_from_template(template) do
    ~r/<%=\s*(\w*)\s*%>/U
    |> Regex.scan(template, capture: :all_but_first)
    |> Enum.map(fn [variable_name] -> String.to_atom(variable_name) end)
  end
end
