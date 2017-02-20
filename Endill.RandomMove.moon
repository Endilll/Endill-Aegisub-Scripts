export script_name        = "Random Move"
export script_description = "Generate multiple lines with different \\moves."
export scrip_author       = "Endill"
export script_version     = "0.2.0"
export script_namespace   = "Endill.RandomMove"


help_text = "Read the hints. Configure the script carefully.

Each of x1, y1, x2, y2, t1 and t2 can be:
— User-specified value (the first input field)
— Taken from existing \\move (\"From line\" checkbox)
— Randomly generated using given range (\"Random\" checkbox and the next two fields)
— Calculated using another parameter or the same (\"Bound to\" checkbox, the next two dropdown lists and the last field)

By default the parameters are set by the user. If you want them to be taken from existing \\move, randomized or calculated using another parameter, don't forget to check the corresponding checkbox.

When single line is selected, the script will generate as many lines as specified in \"Number of lines\" field using \\move from the active line for \"From line\" parameters.
When multiple lines are selected, the script will add generated \\moves in the beginning of the selected lines, or it will replace existing \\move. \"From line\" parameters will be taken from each line, so they may vary just as \\moves in selected lines.
Note that syntactically invalid \\moves will be completely ignored.

Tips:
Produced \\move will consist of 4 parameters, if both t1 and t2 remains untouched (or \"Predefined\" field is 0 and all checkboxes are unchecked).
If you want a parameter to be the same as another, check \"Relative\" and select the desired parameter in \"Base parameter\" dropdown list, while not choosing anything in \"Sign\"  dropdown list. You don't need workarounds like \"+0\"."


have_dc, DependencyControl = pcall require, "l0.DependencyControl"

versionRecord = nil
if have_dc
	versionRecord = DependencyControl {
		url: "https://github.com/Endilll/Endill-Aegisub-Scripts"
		feed: "https://raw.githubusercontent.com/Endilll/Endill-Aegisub-Scripts/master/DependencyControl.json"
		{
      "aegisub.re",
      "aegisub.util"
		}
	}
	re, util = versionRecord\requireModules!

else
	re   = require "aegisub.re"
	util = require "aegisub.util"


main_layout = {
  { name: "x1_lbl", class: "label", x: 0, y: 0, label: "x1" }
  { name: "y1_lbl", class: "label", x: 0, y: 1, label: "y1" }
  { name: "x2_lbl", class: "label", x: 0, y: 2, label: "x2" }
  { name: "y2_lbl", class: "label", x: 0, y: 3, label: "y2" }
  { name: "t1_lbl", class: "label", x: 0, y: 4, label: "t1" }
  { name: "t2_lbl", class: "label", x: 0, y: 5, label: "t2" }
  { name: "x1_const_edt", class: "floatedit", x: 1, y: 0, step: 1, hint: "User-specified value" }
  { name: "y1_const_edt", class: "floatedit", x: 1, y: 1, step: 1, hint: "User-specified value" }
  { name: "x2_const_edt", class: "floatedit", x: 1, y: 2, step: 1, hint: "User-specified value" }
  { name: "y2_const_edt", class: "floatedit", x: 1, y: 3, step: 1, hint: "User-specified value" }
  { name: "t1_const_edt", class: "floatedit", x: 1, y: 4, step: 1, hint: "User-specified value" }
  { name: "t2_const_edt", class: "floatedit", x: 1, y: 5, step: 1, hint: "User-specified value" }
  { name: "x1_from_line_chk", class: "checkbox", x: 2, y: 0, label: "From line", hint: "Value will be taken from existing \\move" }
  { name: "y1_from_line_chk", class: "checkbox", x: 2, y: 1, label: "From line", hint: "Value will be taken from existing \\move" }
  { name: "x2_from_line_chk", class: "checkbox", x: 2, y: 2, label: "From line", hint: "Value will be taken from existing \\move" }
  { name: "y2_from_line_chk", class: "checkbox", x: 2, y: 3, label: "From line", hint: "Value will be taken from existing \\move" }
  { name: "t1_from_line_chk", class: "checkbox", x: 2, y: 4, label: "From line", hint: "Value will be taken from existing \\move" }
  { name: "t2_from_line_chk", class: "checkbox", x: 2, y: 5, label: "From line", hint: "Value will be taken from existing \\move" }
  { name: "x1_random_chk", class: "checkbox", x: 3, y: 0, label: "Random", hint: "Value will be random" }
  { name: "y1_random_chk", class: "checkbox", x: 3, y: 1, label: "Random", hint: "Value will be random" }
  { name: "x2_random_chk", class: "checkbox", x: 3, y: 2, label: "Random", hint: "Value will be random" }
  { name: "y2_random_chk", class: "checkbox", x: 3, y: 3, label: "Random", hint: "Value will be random" }
  { name: "t1_random_chk", class: "checkbox", x: 3, y: 4, label: "Random", hint: "Value will be random" }
  { name: "t2_random_chk", class: "checkbox", x: 3, y: 5, label: "Random", hint: "Value will be random" }
  { name: "x1_random_lower_edt", class: "intedit", x: 4, y: 0, hint: "Start of range for random" }
  { name: "y1_random_lower_edt", class: "intedit", x: 4, y: 1, hint: "Start of range for random" }
  { name: "x2_random_lower_edt", class: "intedit", x: 4, y: 2, hint: "Start of range for random" }
  { name: "y2_random_lower_edt", class: "intedit", x: 4, y: 3, hint: "Start of range for random" }
  { name: "t1_random_lower_edt", class: "intedit", x: 4, y: 4, hint: "Start of range for random" }
  { name: "t2_random_lower_edt", class: "intedit", x: 4, y: 5, hint: "Start of range for random" }
  { name: "x1_random_lbl", class: "label", x: 5, y: 0, label: "—" }
  { name: "y1_random_lbl", class: "label", x: 5, y: 1, label: "—" }
  { name: "x2_random_lbl", class: "label", x: 5, y: 2, label: "—" }
  { name: "y2_random_lbl", class: "label", x: 5, y: 3, label: "—" }
  { name: "t1_random_lbl", class: "label", x: 5, y: 4, label: "—" }
  { name: "t2_random_lbl", class: "label", x: 5, y: 5, label: "—" }
  { name: "x1_random_upper_edt", class: "intedit", x: 6, y: 0, hint: "End of range for random" }
  { name: "y1_random_upper_edt", class: "intedit", x: 6, y: 1, hint: "End of range for random" }
  { name: "x2_random_upper_edt", class: "intedit", x: 6, y: 2, hint: "End of range for random" }
  { name: "y2_random_upper_edt", class: "intedit", x: 6, y: 3, hint: "End of range for random" }
  { name: "t1_random_upper_edt", class: "intedit", x: 6, y: 4, hint: "End of range for random" }
  { name: "t2_random_upper_edt", class: "intedit", x: 6, y: 5, hint: "End of range for random" }
  { name: "x1_relative_chk", class: "checkbox", x: 7, y: 0, label: "Bound to", hint: "Value will be calculated using another parameter" }
  { name: "y1_relative_chk", class: "checkbox", x: 7, y: 1, label: "Bound to", hint: "Value will be calculated using another parameter" }
  { name: "x2_relative_chk", class: "checkbox", x: 7, y: 2, label: "Bound to", hint: "Value will be calculated using another parameter" }
  { name: "y2_relative_chk", class: "checkbox", x: 7, y: 3, label: "Bound to", hint: "Value will be calculated using another parameter" }
  { name: "t1_relative_chk", class: "checkbox", x: 7, y: 4, label: "Bound to", hint: "Value will be calculated using another parameter" }
  { name: "t2_relative_chk", class: "checkbox", x: 7, y: 5, label: "Bound to", hint: "Value will be calculated using another parameter" }
  { name: "x1_relative_base_cbb", class: "dropdown", x: 8, y: 0, items: {   "", "y1", "x2", "y2", "t1", "t2" }, hint: "Base parameter" }
  { name: "y1_relative_base_cbb", class: "dropdown", x: 8, y: 1, items: { "x1",   "", "x2", "y2", "t1", "t2" }, hint: "Base parameter" }
  { name: "x2_relative_base_cbb", class: "dropdown", x: 8, y: 2, items: { "x1", "y1",   "", "y2", "t1", "t2" }, hint: "Base parameter" }
  { name: "y2_relative_base_cbb", class: "dropdown", x: 8, y: 3, items: { "x1", "y1", "x2",   "", "t1", "t2" }, hint: "Base parameter" }
  { name: "t1_relative_base_cbb", class: "dropdown", x: 8, y: 4, items: { "x1", "y1", "x2", "y2",   "", "t2" }, hint: "Base parameter" }
  { name: "t2_relative_base_cbb", class: "dropdown", x: 8, y: 5, items: { "x1", "y1", "x2", "y2", "t1",   "" }, hint: "Base parameter" }
  { name: "x1_relative_sign_cbb", class: "dropdown", x: 9, y: 0, items: { "", "+", "-", "*", "/", "^" }, hint: "Arithmetic operator" }
  { name: "y1_relative_sign_cbb", class: "dropdown", x: 9, y: 1, items: { "", "+", "-", "*", "/", "^" }, hint: "Arithmetic operator" }
  { name: "x2_relative_sign_cbb", class: "dropdown", x: 9, y: 2, items: { "", "+", "-", "*", "/", "^" }, hint: "Arithmetic operator" }
  { name: "y2_relative_sign_cbb", class: "dropdown", x: 9, y: 3, items: { "", "+", "-", "*", "/", "^" }, hint: "Arithmetic operator" }
  { name: "t1_relative_sign_cbb", class: "dropdown", x: 9, y: 4, items: { "", "+", "-", "*", "/", "^" }, hint: "Arithmetic operator" }
  { name: "t2_relative_sign_cbb", class: "dropdown", x: 9, y: 5, items: { "", "+", "-", "*", "/", "^" }, hint: "Arithmetic operator" }
  { name: "x1_relative_edt", class: "floatedit", x: 10, y: 0, step: 0.1, hint: "Second argument for arithmetic operator" }
  { name: "y1_relative_edt", class: "floatedit", x: 10, y: 1, step: 0.1, hint: "Second argument for arithmetic operator" }
  { name: "x2_relative_edt", class: "floatedit", x: 10, y: 2, step: 0.1, hint: "Second argument for arithmetic operator" }
  { name: "y2_relative_edt", class: "floatedit", x: 10, y: 3, step: 0.1, hint: "Second argument for arithmetic operator" }
  { name: "t1_relative_edt", class: "floatedit", x: 10, y: 4, step: 0.1, hint: "Second argument for arithmetic operator" }
  { name: "t2_relative_edt", class: "floatedit", x: 10, y: 5, step: 0.1, hint: "Second argument for arithmetic operator" }
  { name: "lines_lbl", class: "label", x: 0, y: 6, label: "Lines" }
  { name: "lines_edt", class: "intedit", x: 1, y: 6, value: 1, hint: "Number of lines to generate" }
}
main_buttons = { "Help" , "Generate", "Quit" }
main_button_ids = { help: "Help", ok: "Generate", close: "Quit" }

help_layout = { { class: "textbox", x: 0, y: 0, width: 50, height: 10, text: help_text, hint: "Help"} }
help_buttons = { "Back" }
help_buttons_ids = { close: "Back" }

form = {}


error = (message) ->
  aegisub.log "#{message}.\n"
  aegisub.cancel!


generate_move = (default_parameters, line_index, has_move) ->
  aegisub.progress.task "Generating \\move"
  parameters = {
    x1: nil
    y1: nil
    x2: nil
    y2: nil
    t1: nil
    t2: nil
  }
  parameters_to_iterate_over = { { "x1", "y1", "x2", "y2", "t1", "t2" } }
  pass_index = 1
  while pass_index <= #parameters_to_iterate_over
    next_pass = {}
    for parameter in *parameters_to_iterate_over[pass_index]
      type = 0
      type += 1 if form[parameter .. "_from_line_chk"] == true
      type += 2 if form[parameter .. "_random_chk"] == true
      type += 4 if form[parameter .. "_relative_chk"] == true

      switch type
        when 0
          parameters[parameter] = form[parameter .. "_const_edt"]

        when 1
          if default_parameters[parameter] == nil
            if has_move
              error "\\move in the line #{line_index} doesn't have \"#{parameter}\" parameter"
            else
              error "The line #{line_index} doesn't have \\move"

          parameters[parameter] = default_parameters[parameter]

        when 2
          lower_bound = form[parameter .. "_random_lower_edt"]
          upper_bound = form[parameter .. "_random_upper_edt"]

          if upper_bound - lower_bound <= 1
            error "#{parameter}: The range for random is too small"

          parameters[parameter] = math.random(lower_bound, upper_bound)

        when 4
          if form[parameter .. "_relative_base_cbb"] == ""
            error "#{parameter}: \"Relative\" checkbox is checked, but the base isn't specified"

          base = parameters[form[parameter .. "_relative_base_cbb"]]
          second_argument = form[parameter .. "_relative_edt"]
          if base == nil
            table.insert next_pass, parameter
          else
            switch form[parameter .. "_relative_sign_cbb"]
              when  "" then parameters[parameter] = base
              when "+" then parameters[parameter] = base + second_argument
              when "-" then parameters[parameter] = base - second_argument
              when "*" then parameters[parameter] = base * second_argument
              when "/" then parameters[parameter] = base / second_argument
              when "^" then parameters[parameter] = base ^ second_argument

        when 3, 5, 6, 7
          error "#{parameter}: Multiple checkboxes are checked"

        else
          error "#{parameter}: Something really weird happend with checkboxes"

    if pass_index <= 6
      pass_index += 1
    else
      error "A loop has occured. Please check your \"Bound to\" parameters"

    table.insert parameters_to_iterate_over, next_pass if #next_pass > 0

  with parameters
    if .t1 == 0 and .t2 == 0
      return "\\\\move(#{.x1},#{.y1},#{.x2},#{.y2})"
    else
      return "\\\\move(#{.x1},#{.y1},#{.x2},#{.y2},#{.t1},#{.t2})"


add_new_move_to_line = (line, has_move, default_parameters, line_index) ->
  aegisub.progress.task "Deciding where to put new \\move"
  new_line = util.deep_copy(line)
  if has_move
    new_line.text = re.sub(new_line.text, "\\\\move\\(((-?\\d+,){3}|(-?\\d+,){5})-?\\d+?\\)", generate_move(default_parameters, line_index, has_move), 1)
  elseif re.match(new_line.text, "{\\\\.+?}")
    new_line.text = re.sub(new_line.text, "{(\\\\.+?)}", "{#{generate_move(default_parameters, line_index, has_move)}$1}", 1)
  else
    new_line.text = re.sub(new_line.text, "^(.*)$", "{#{generate_move(default_parameters, line_index, has_move)}}$1", 1)
  return new_line


get_default_parameters = (line) ->
  aegisub.progress.task "Parsing line"
  has_move = false
  default_parameters = {}
  if match = re.match(line.text, "{.*\\\\move\\((-?\\d+),(-?\\d+),(-?\\d+),(-?\\d+)\\).*}")
    has_move = true
    with default_parameters
      { {str: full_move}, {str: .x1}, {str: .y1}, {str: .x2}, {str: .y2} } = match
      .t1 = 0
      .t2 = line.end_time - line.start_time
  if match = re.match(line.text, "{.*\\\\move\\((-?\\d+),(-?\\d+),(-?\\d+),(-?\\d+),(-?\\d+),(-?\\d+)\\).*}")
    has_move = true
    with default_parameters
      { {str: full_move}, {str: .x1}, {str: .y1}, {str: .x2}, {str: .y2}, {str: .t1}, {str: .t2} } = match
  return has_move, default_parameters


get_first_line_index = (subtitles) ->
  aegisub.progress.task "Getting index of the first visible line"
  for i = 1, #subtitles
    if subtitles[i].class == "dialogue"
      return i


main = (subtitles, selected_lines, active_line_index) ->
  pressed_btn = ""
  while pressed_btn != "Generate"
    pressed_btn, form = aegisub.dialog.display main_layout, main_buttons, main_button_ids
    switch pressed_btn
      when "Quit"
        aegisub.cancel!
      when "Help"
        aegisub.dialog.display help_layout, help_buttons, help_buttons_ids

  aegisub.progress.set 0
  first_line_index = get_first_line_index(subtitles)
  backuped_effects = {}

  for i = #selected_lines, 1, -1
    line_index = selected_lines[i]
    line = subtitles[line_index]
    backuped_effects[line_index] = line.effect unless line.effect == ""
    has_move, default_parameters = get_default_parameters(line)

    for j = 1, form.lines_edt
      new_line = add_new_move_to_line(line, has_move, default_parameters, line_index - first_line_index + 1)
      new_line.effect = "random_move_original_line_#{line_index}"
      subtitles[-(line_index + 1)] = new_line
      aegisub.progress.set(math.floor((i * form.lines_edt + j) / (#selected_lines * form.lines_edt * 100)))
    subtitles.delete line_index

  aegisub.progress.task "Adding generated lines to selection"
  for i = 1, #subtitles
    if subtitles[i].class == "dialogue"
      if match = re.match(subtitles[i].effect, "random_move_original_line_(\\d+)")
        line = subtitles[i]
        original_line_index = tonumber(match[2].str)
        if original_effect = backuped_effects[original_line_index]
          line.effect = original_effect
        else
          line.effect = ""
        subtitles[i] = line

        selected_lines[#selected_lines + 1] = i

  aegisub.set_undo_point script_name
  return selected_lines, selected_lines[#selected_lines]


if have_dc
  versionRecord\registerMacro main
else
  aegisub.register_macro script_name, script_description, main, () -> true
