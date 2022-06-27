import * as core from "@actions/core";
import * as github from "@actions/github";
import dayjs from "dayjs";

async function run() {
  try {
    const token = (core.getInput("github_token") ||
      process.env.GITHUB_TOKEN) as string;

    const octokit = github.getOctokit(token);
    const context = github.context;

    const tagName = core.getInput("tag") || dayjs().format("YY.MMDDmm.ss");
    const message = core.getInput("message");

    const tagRequest = await octokit.rest.git.createTag({
      ...context.repo,
      message,
      tag: tagName,
      type: "commit",
      object: context.sha,
    });

    const tag = tagRequest.data;

    const refRequest = await octokit.rest.git.createRef({
      sha: tag.object.sha,
      repo: context.repo.repo,
      owner: context.repo.owner,
      ref: `refs/tags/${tag.tag}`,
    });

    const ref = refRequest.data;
    core.setOutput("ref", ref.ref);
  } catch (error) {
    core.setFailed(error?.message);
  }
}

run();
