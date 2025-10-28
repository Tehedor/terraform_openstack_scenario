find . -name "variables.tf" -not -path "./temporal_variables.tf" -exec cat {} \; > temporal_variables.tf

