name "rails"
description "Rails app on unicorn/apache"
run_list (
  "recipe[chef-rack_stack]"
)
override_attributes(
  "nodejs" => { "install_method" => "package" }
)

