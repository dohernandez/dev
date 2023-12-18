// Package dev contains reusable development helpers.
package dev

// These imports workaround `go mod vendor` prune.
//
// See https://github.com/golang/go/issues/26366.
import (
	_ "github.com/dohernandez/dev/makefiles" // Include dev to project.
	_ "github.com/dohernandez/dev/scripts"
)
