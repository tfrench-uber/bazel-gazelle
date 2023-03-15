load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//internal/bzlmod:go_mod.bzl", "parse_go_mod", "parse_go_sum")

_GO_MOD_CONTENT = """ go 1.18

require (
  github.com/bazelbuild/buildtools v0.0.0-20220531122519-a43aed7014c8
	github.com/bazelbuild/rules_go "v0.\\n\\\\\\"33.0"
github.com/bmatcuk/doublestar/v4 v4.0.2 // indirect
	// some comment
	`golang.org/x/tools` "v0.1.11" // foobar
	github.com/go-fsnotify/fsnotify v1.5.4
)

replace github.com/go-fsnotify/fsnotify => github.com/fsnotify/fsnotify v1.4.2

module github.com/bazelbuild/bazel-gazelle

	exclude    (
	github.com/bazelbuild/rules_go v0.33.0
  )

  retract v1.0.0

require golang.org/x/sys v0.0.0-20220624220833-87e55d714810 // indirect
"""

_EXPECTED_GO_MOD_PARSE_RESULT = struct(
    go = (1, 18),
    module = "github.com/bazelbuild/bazel-gazelle",
    replace_map = {"github.com/go-fsnotify/fsnotify": struct(to_path = "github.com/fsnotify/fsnotify", version = "1.4.2")},
    require = (
        struct(direct = True, path = "github.com/bazelbuild/buildtools", version = "v0.0.0-20220531122519-a43aed7014c8"),
        struct(direct = True, path = "github.com/bazelbuild/rules_go", version = "v0.n\\\"33.0"),
        struct(direct = False, path = "github.com/bmatcuk/doublestar/v4", version = "v4.0.2"),
        struct(direct = True, path = "golang.org/x/tools", version = "v0.1.11"),
        struct(direct = True, path = "github.com/go-fsnotify/fsnotify", version = "v1.5.4"),
        struct(direct = False, path = "golang.org/x/sys", version = "v0.0.0-20220624220833-87e55d714810"),
    ),
)

def _go_mod_test_impl(ctx):
    env = unittest.begin(ctx)
    asserts.equals(env, _EXPECTED_GO_MOD_PARSE_RESULT, parse_go_mod(_GO_MOD_CONTENT, "/go.mod"))
    return unittest.end(env)

go_mod_test = unittest.make(_go_mod_test_impl)

_GO_SUM_CONTENT = """cloud.google.com/go v0.26.0/go.mod h1:aQUYkXzVsufM+DwF1aE+0xfcU+56JwCaLick0ClmMTw=
github.com/BurntSushi/toml v0.3.1/go.mod h1:xHWCNGjB5oqiDr8zfno3MHue2Ht5sIBksp03qcyfWMU=
github.com/bazelbuild/buildtools v0.0.0-20220531122519-a43aed7014c8 h1:fmdo+fvvWlhldUcqkhAMpKndSxMN3vH5l7yow5cEaiQ=
github.com/bazelbuild/buildtools v0.0.0-20220531122519-a43aed7014c8/go.mod h1:689QdV3hBP7Vo9dJMmzhoYIyo/9iMhEmHkJcnaPRCbo=
github.com/bazelbuild/rules_go v0.33.0 h1:WW9CHmFxbE+Lm4qiLOFAPogmiAUzZtvQsWxUcm4wwaU=
github.com/bazelbuild/rules_go v0.33.0/go.mod h1:MC23Dc/wkXEyk3Wpq6lCqz0ZAYOZDw2DR5y3N1q2i7M=
"""

_EXPECTED_GO_SUM_PARSE_RESULT = {
    ("github.com/bazelbuild/buildtools", "0.0.0-20220531122519-a43aed7014c8"): "h1:fmdo+fvvWlhldUcqkhAMpKndSxMN3vH5l7yow5cEaiQ=",
    ("github.com/bazelbuild/rules_go", "0.33.0"): "h1:WW9CHmFxbE+Lm4qiLOFAPogmiAUzZtvQsWxUcm4wwaU=",
}

def _go_sum_test_impl(ctx):
    env = unittest.begin(ctx)
    asserts.equals(env, _EXPECTED_GO_SUM_PARSE_RESULT, parse_go_sum(_GO_SUM_CONTENT))
    return unittest.end(env)

go_sum_test = unittest.make(_go_sum_test_impl)

def go_mod_test_suite(name):
    unittest.suite(
        name,
        go_mod_test,
        go_sum_test,
    )
