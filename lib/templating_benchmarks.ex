defmodule TemplatingBenchmarks do
  def base_templating(template, bindings) do
    Enum.map(bindings, fn binding ->
      Enum.reduce(binding, template, fn {variable_name, variable_value}, acc ->
        {:ok, regex} = Regex.compile("<%= #{variable_name} %>")
        Regex.replace(regex, acc, variable_value)
      end)
    end)
  end

  # def eex_templating(template, bindings) do
  #   variable_names = bindings |> hd |> Keyword.keys
  #   IO.inspect(variable_names, label: :variable_names)
  #   # compiled = EEx.compile_string(template)
  #   module_body =
  #     quote bind_quoted: [template: template, variable_names: variable_names] do
  #       require EEx
  #       EEx.function_from_string(:def, :example, template, variable_names)
  #     end

  #   Module.create(EexExampleModule, module_body, Macro.Env.location(__ENV__))

  #   Enum.map(bindings, fn binding ->
  #     # {result, _} = Code.eval_quoted(compiled, binding)
  #     # result
  #     EexExampleModule.example(Keyword.values(binding))
  #   end)
  # end

  def eex_templating_create(template, variable_names) do
    module_body =
      quote bind_quoted: [template: template, variable_names: variable_names] do
      require EEx
      EEx.function_from_string(:def, :example, template, variable_names)
    end

    Module.create(EexExampleModule, module_body, Macro.Env.location(__ENV__))
  end

  def eex_templating_run(bindings) do
    Enum.map(bindings, fn binding ->
      # {result, _} = Code.eval_quoted(compiled, binding)
      # result
      apply(EexExampleModule, :example, Keyword.values(binding))
    end)
  end

  def eex_eval_string_templating(template, bindings) do
    Enum.map(bindings, fn binding ->
      EEx.eval_string(template, binding)
    end)
  end

  def manual_templating(template, bindings) do
    compiled_template = compile_template(template)

    Enum.map(bindings, fn binding ->
      fill_template(compiled_template, binding)
    end)
  end

  defp fill_template({first_part, variable_with_template}, binding) do
    map_binding = Enum.reduce(binding, %{}, fn {key, value}, acc -> Map.put(acc, key, value) end)

    Enum.reduce(variable_with_template, first_part, fn {part, variable_name}, acc ->
      acc <> Map.get(map_binding, String.to_atom(variable_name)) <> part
    end)
  end

  defp compile_template(template) do
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
      |> Enum.map(fn [variable] -> String.trim(variable) end)

    [first_part | remaining_parts] =
      Enum.map(parts, fn part ->
        [filtered_part | _] = String.split(part, "<%=")
        filtered_part
      end)

    {first_part, Enum.zip(remaining_parts, variables)}
  end

  def create_bindings(nb_bindings, variables) do
    Enum.map(0..nb_bindings, fn iteration ->
      Enum.map(variables, fn variable_name -> {variable_name, "#{variable_name}-#{iteration}"} end)
    end)
  end
end
