// Package actions keeps github actions in vendor.
package actions

// These imports workaround `go mod vendor` prune.
//
// See https://github.com/golang/go/issues/26366.
import (
	_ "github.com/dohernandez/dev/templates/github/actions/check-branch" // Include dev to project.
)
