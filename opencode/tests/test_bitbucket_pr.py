import contextlib
import io
import os
import subprocess
import sys
import unittest
from importlib.machinery import SourceFileLoader
from importlib.util import module_from_spec, spec_from_loader
from pathlib import Path
from types import SimpleNamespace
from unittest import mock


SCRIPT = Path(__file__).parents[1] / ".local" / "bin" / "bitbucket-pr"
LOADER = SourceFileLoader("bitbucket_pr", str(SCRIPT))
SPEC = spec_from_loader("bitbucket_pr", LOADER)
bitbucket_pr = module_from_spec(SPEC)
LOADER.exec_module(bitbucket_pr)


class RepositoryIdentityTests(unittest.TestCase):
    def test_accepts_both_bitbucket_hosts_and_remote_formats(self):
        remotes = (
            "git@bitbucket.org:workspace/repo.git",
            "git@ssh.bitbucket.org:workspace/repo.git",
            "ssh://git@bitbucket.org/workspace/repo.git",
            "ssh://git@ssh.bitbucket.org/workspace/repo.git",
            "https://bitbucket.org/workspace/repo.git",
            "https://ssh.bitbucket.org/workspace/repo.git",
        )

        for remote in remotes:
            with self.subTest(remote=remote):
                with mock.patch.object(bitbucket_pr, "run_git", return_value=remote):
                    self.assertEqual(
                        bitbucket_pr.repository_identity(), ("workspace", "repo")
                    )

    def test_rejects_remote_hosts_outside_bitbucket(self):
        remotes = (
            "git@github.com:workspace/repo.git",
            "ssh://git@github.com/workspace/repo.git",
            "https://github.com/workspace/repo.git",
        )

        for remote in remotes:
            with self.subTest(remote=remote):
                with mock.patch.object(bitbucket_pr, "run_git", return_value=remote):
                    with self.assertRaisesRegex(
                        bitbucket_pr.HelperError, "origin must point to"
                    ):
                        bitbucket_pr.repository_identity()


class ResolveTokenTests(unittest.TestCase):
    @mock.patch.object(bitbucket_pr, "executable_path", return_value="/usr/bin/pass")
    @mock.patch.object(bitbucket_pr.subprocess, "run")
    def test_noninteractive_lookup_forbids_pinentry(self, run, _executable_path):
        run.return_value = SimpleNamespace(stdout=b"test-token\n")

        with mock.patch.dict(os.environ, {"PASSWORD_STORE_GPG_OPTS": "--test-option"}):
            token = bitbucket_pr.resolve_token(
                "bitbucket/opencode", non_interactive=True
            )

        self.assertEqual(token, "test-token")
        options = run.call_args.kwargs
        self.assertIs(options["stdin"], subprocess.DEVNULL)
        self.assertEqual(options["timeout"], bitbucket_pr.PASS_TIMEOUT_SECONDS)
        gpg_options = options["env"]["PASSWORD_STORE_GPG_OPTS"]
        self.assertTrue(gpg_options.startswith("--test-option "))
        for required_option in (
            "--batch",
            "--no-tty",
            "--pinentry-mode error",
        ):
            self.assertIn(required_option, gpg_options)

    @mock.patch.object(bitbucket_pr, "executable_path", return_value="/usr/bin/pass")
    @mock.patch.object(bitbucket_pr.subprocess, "run")
    def test_interactive_lookup_keeps_terminal_input(self, run, _executable_path):
        run.return_value = SimpleNamespace(stdout=b"test-token\n")

        bitbucket_pr.resolve_token("bitbucket/opencode")

        options = run.call_args.kwargs
        self.assertNotIn("stdin", options)
        self.assertNotIn("env", options)
        self.assertNotIn("timeout", options)

    @mock.patch.object(bitbucket_pr, "executable_path", return_value="/usr/bin/pass")
    @mock.patch.object(bitbucket_pr.subprocess, "run")
    def test_locked_key_error_does_not_expose_pass_output(self, run, _executable_path):
        run.side_effect = subprocess.CalledProcessError(
            1,
            ["pass", "show", "bitbucket/opencode"],
            output=b"untrusted output",
            stderr=b"pinentry diagnostic",
        )

        with self.assertRaises(bitbucket_pr.HelperError) as error:
            bitbucket_pr.resolve_token("bitbucket/opencode", non_interactive=True)

        self.assertNotIn("untrusted output", str(error.exception))
        self.assertNotIn("pinentry diagnostic", str(error.exception))

    @mock.patch.object(bitbucket_pr, "executable_path", return_value="/usr/bin/pass")
    @mock.patch.object(bitbucket_pr.subprocess, "run", side_effect=subprocess.TimeoutExpired("pass", 10))
    def test_noninteractive_lookup_timeout_is_safe(self, _run, _executable_path):
        with self.assertRaisesRegex(
            bitbucket_pr.HelperError, "no interactive prompt was opened"
        ):
            bitbucket_pr.resolve_token("bitbucket/opencode", non_interactive=True)

    @mock.patch.object(bitbucket_pr, "executable_path", return_value="/usr/bin/pass")
    @mock.patch.object(bitbucket_pr.subprocess, "run", return_value=SimpleNamespace(stdout=b""))
    def test_empty_pass_output_is_reported_safely(self, _run, _executable_path):
        with self.assertRaisesRegex(bitbucket_pr.HelperError, "empty Bitbucket token"):
            bitbucket_pr.resolve_token("bitbucket/opencode", non_interactive=True)


class AuthCommandTests(unittest.TestCase):
    @mock.patch.object(bitbucket_pr, "resolve_token", return_value="test-token")
    @mock.patch.object(bitbucket_pr, "load_config", return_value={"pass_name": "test"})
    def test_noninteractive_auth_flag_selects_noninteractive_lookup(
        self, _load_config, resolve_token
    ):
        output = io.StringIO()
        with mock.patch.object(
            sys,
            "argv",
            [str(SCRIPT), "auth", "check", "--non-interactive"],
        ), contextlib.redirect_stdout(output):
            result = bitbucket_pr.main()

        self.assertEqual(result, 0)
        resolve_token.assert_called_once_with("test", non_interactive=True)
        self.assertNotIn("test-token", output.getvalue())

    @mock.patch.object(bitbucket_pr, "resolve_token", return_value="test-token")
    @mock.patch.object(bitbucket_pr, "load_config", return_value={"pass_name": "test"})
    def test_plain_auth_check_remains_interactive(self, _load_config, resolve_token):
        with mock.patch.object(sys, "argv", [str(SCRIPT), "auth", "check"]), contextlib.redirect_stdout(io.StringIO()):
            result = bitbucket_pr.main()

        self.assertEqual(result, 0)
        resolve_token.assert_called_once_with("test", non_interactive=False)


class CreateCommandTests(unittest.TestCase):
    @mock.patch.object(bitbucket_pr, "repository_identity", return_value=("workspace", "repo"))
    @mock.patch.object(bitbucket_pr, "current_branch", return_value="feature/test")
    @mock.patch.object(bitbucket_pr, "load_config", return_value={"pass_name": "test"})
    @mock.patch.object(
        bitbucket_pr,
        "resolve_token",
        side_effect=bitbucket_pr.HelperError("credential unavailable"),
    )
    @mock.patch.object(bitbucket_pr, "find_existing_pr")
    def test_create_uses_noninteractive_auth_and_stops_before_api(
        self, find_existing_pr, resolve_token, _load_config, _current_branch, _repository_identity
    ):
        output = io.StringIO()
        with mock.patch.object(
            sys, "argv", [str(SCRIPT), "create", "--title", "Test PR"]
        ), contextlib.redirect_stderr(output):
            result = bitbucket_pr.main()

        self.assertEqual(result, 1)
        resolve_token.assert_called_once_with("test", non_interactive=True)
        find_existing_pr.assert_not_called()
        self.assertIn("credential unavailable", output.getvalue())

    @mock.patch.object(bitbucket_pr, "repository_identity", return_value=("workspace", "repo"))
    @mock.patch.object(bitbucket_pr, "current_branch", return_value="feature/test")
    @mock.patch.object(bitbucket_pr, "load_config")
    @mock.patch.object(bitbucket_pr, "resolve_token")
    def test_dry_run_does_not_resolve_credentials(
        self, resolve_token, load_config, _current_branch, _repository_identity
    ):
        output = io.StringIO()
        with mock.patch.object(
            sys,
            "argv",
            [str(SCRIPT), "create", "--title", "Test PR", "--dry-run"],
        ), contextlib.redirect_stdout(output):
            result = bitbucket_pr.main()

        self.assertEqual(result, 0)
        load_config.assert_not_called()
        resolve_token.assert_not_called()
        self.assertIn('"title": "Test PR"', output.getvalue())


if __name__ == "__main__":
    unittest.main()
