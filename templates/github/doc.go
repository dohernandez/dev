// Package workflows keep github actions in vendor.
package workflows

// These imports workaround `go mod vendor` prune.
//
// See https://github.com/golang/go/issues/26366.
import (
	_ "github.com/dohernandez/dev/templates/github/actions" // Include dev to project.
	_ "github.com/dohernandez/dev/templates/github/workflows"
)
