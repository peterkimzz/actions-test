import * as core from "@actions/core";
import * as github from "@actions/github";
import dayjs from "dayjs";

async function run() {
  try {
    const token = (core.getInput("github_token") ||
      process.env.GITHUB_TOKEN) as string;

    const octokit = github.getOctokit(token);
    const context = github.context;

    const sha = core.getInput("sha") || context.sha;
    const tagName = core.getInput("tag") || dayjs().format("YY.MM.DD.sss");
    const message = core.getInput("message");

    const tagRequest = await octokit.rest.git.createTag({
      ...context.repo,
      tag: tagName,
      message,
      object: sha,
      type: "commit",
    });

    const tag = tagRequest.data;

    const refRequest = await octokit.rest.git.createRef({
      owner: context.repo.owner,
      repo: context.repo.repo,
      ref: `refs/tags/${tag.tag}`,
      sha: tag.object.sha,
    });

    const ref = refRequest.data;
    core.setOutput("ref", ref.ref);
  } catch (error) {
    core.setFailed(error?.message);
  }
}

run();
