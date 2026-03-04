// PM Copilot: Check if product context exists when PM-related terms are used
// This hook fires on UserPromptSubmit and reads the user's prompt from stdin (JSON)

const fs = require("fs");

let input = "";
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  let prompt = "";
  try {
    prompt = JSON.parse(input).prompt || "";
  } catch {
    process.exit(0);
  }

  const pmTerms =
    /feature spec|product spec|PRD|product requirements|feature request|backlog|user story|acceptance criteria|feature drill|product context|KPI|success metric/i;

  if (pmTerms.test(prompt)) {
    if (!fs.existsSync(".claude/product-context.md")) {
      console.log(
        JSON.stringify({
          message:
            "PM Copilot: No product context found for this project. Run /pm-copilot:pm-init to set up your product context for better results.",
        })
      );
    }
  }

  process.exit(0);
});
