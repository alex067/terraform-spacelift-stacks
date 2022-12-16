package spacelift

track {
	project_affected
	input.push.branch == input.stack.branch
}

track {
	deps_affected
	input.push.branch == input.stack.branch
}

propose {
	project_proposed
}

propose {
	deps_proposed
}

ignore {
	not track
  	not propose
}

ignore {
	input.push.tag != ""
}

project_affected {
	tracked_extensions := [".tf", ".json", ".yaml", ".yml"]
	
	startswith(input.push.affected_files[_], input.stack.project_root)
	endswith(input.push.affected_files[_], tracked_extensions[_])
}

deps_affected {
	tracked_extensions := [".tf", ".json", ".yaml", ".yml"]
	  
	deps := [dep | startswith(input.stack.labels[i], "dep:"); dep := split(input.stack.labels[i], ":")[1]]

	startswith(input.push.affected_files[_], deps[_])
  	endswith(input.push.affected_files[_], tracked_extensions[_])
}

project_proposed {
	tracked_extensions := [".tf", ".json", ".yaml", ".yml"]

  	startswith(input.pull_request.diff[_], input.stack.project_root)
  	endswith(input.pull_request.diff[_], tracked_extensions[_])
}

deps_proposed {
	tracked_extensions := [".tf", ".json", ".yaml", ".yml"]

  	deps := [dep | startswith(input.stack.labels[i], "dep:"); dep := split(input.stack.labels[i], ":")[1]]

  	startswith(input.pull_request.diff[_], deps[_])
  	endswith(input.pull_request.diff[_], tracked_extensions[_]) 
}
