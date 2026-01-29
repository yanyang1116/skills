import * as fs from "node:fs";
import * as path from "node:path";
import * as readline from "node:readline";

type Framework = "react" | "vue";

const VALID_FRAMEWORKS = new Set<Framework>(["react", "vue"]);

function isFramework(value: string): value is Framework {
  return VALID_FRAMEWORKS.has(value as Framework);
}

function printHelp(): void {
  console.log(`\nfeai - Generate frontend prompt files\n\nUsage:\n  feai [--framework <react|vue>]\n  feai [react|vue]\n\nOptions:\n  -f, --framework   Select framework and skip interactive prompt\n  -h, --help        Show help\n`);
}

function parseArgs(argv: string[]): { framework?: Framework; help: boolean } {
  let framework: Framework | undefined;
  let help = false;

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];

    if (arg === "-h" || arg === "--help") {
      help = true;
      continue;
    }

    if (arg === "-f" || arg === "--framework") {
      const value = argv[i + 1];
      if (!value) {
        throw new Error("Missing value for --framework");
      }
      framework = value as Framework;
      i += 1;
      continue;
    }

    if (arg.startsWith("--framework=")) {
      const value = arg.split("=")[1] ?? "";
      framework = value as Framework;
      continue;
    }

    if (!framework && isFramework(arg)) {
      framework = arg;
      continue;
    }

    throw new Error(`Unknown argument: ${arg}`);
  }

  return { framework, help };
}

function askQuestion(question: string): Promise<string> {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  return new Promise((resolve) => {
    rl.question(question, (answer: string) => {
      rl.close();
      resolve(answer);
    });
  });
}

async function chooseFramework(): Promise<Framework> {
  while (true) {
    const answer = await askQuestion("Select framework (react/vue): ");
    const value = answer.trim().toLowerCase();
    if (isFramework(value)) {
      return value;
    }
    console.log("Invalid input. Please enter react or vue.");
  }
}

function removeSection(content: string, marker: Framework): string {
  const pattern = new RegExp(
    `\\n<!-- FEAI:${marker}:start -->[\\s\\S]*?<!-- FEAI:${marker}:end -->\\n?`,
    "g"
  );

  const updated = content.replace(pattern, "\n");
  return updated.replace(/\n{3,}/g, "\n\n").trimEnd() + "\n";
}

function ensureFileExists(filePath: string, label: string): void {
  if (!fs.existsSync(filePath)) {
    throw new Error(`${label} not found: ${filePath}`);
  }
}

async function main(): Promise<void> {
  const { framework: argFramework, help } = parseArgs(process.argv.slice(2));

  if (help) {
    printHelp();
    return;
  }

  let framework = argFramework;
  if (framework) {
    framework = framework.trim().toLowerCase() as Framework;
    if (!isFramework(framework)) {
      throw new Error(`Unsupported framework: ${framework}`);
    }
  } else {
    framework = await chooseFramework();
  }

  const rootDir = process.cwd();
  const outputDir = path.join(rootDir, "dist", "fe-prompt");
  const outputPromptDir = path.join(outputDir, "system-prompt");

  const distAssetsDir = path.join(__dirname, "assets");
  const isProduction = process.env.NODE_ENV === "production";
  if (isProduction && !fs.existsSync(distAssetsDir)) {
    throw new Error(
      `Assets not found: ${distAssetsDir}. Run the build command to generate dist assets first.`
    );
  }

  const assetsBase = isProduction ? distAssetsDir : __dirname;
  const templatePath = path.join(assetsBase, "template", "AGENT.md");
  const promptDir = path.join(assetsBase, "system-prompt");

  ensureFileExists(templatePath, "模板文件");
  ensureFileExists(promptDir, "system-prompt directory");

  fs.rmSync(outputDir, { recursive: true, force: true });
  fs.mkdirSync(outputPromptDir, { recursive: true });

  const template = fs.readFileSync(templatePath, "utf8");
  const removeMarker: Framework = framework === "react" ? "vue" : "react";
  const agentContent = removeSection(template, removeMarker);
  fs.writeFileSync(path.join(outputDir, "AGENT.md"), agentContent);

  const tailwindPath = path.join(promptDir, "tailwind.md");
  const precisionPath = path.join(promptDir, "number-calculation.md");
  const typescriptPath = path.join(promptDir, "typescript.md");
  const frameworkPath = path.join(promptDir, `${framework}.md`);
  ensureFileExists(tailwindPath, "tailwind file");
  ensureFileExists(precisionPath, "number-calculation file");
  ensureFileExists(typescriptPath, "typescript file");
  ensureFileExists(frameworkPath, "framework file");

  fs.copyFileSync(tailwindPath, path.join(outputPromptDir, "tailwind.md"));
  fs.copyFileSync(
    precisionPath,
    path.join(outputPromptDir, "number-calculation.md")
  );
  fs.copyFileSync(
    typescriptPath,
    path.join(outputPromptDir, "typescript.md")
  );
  fs.copyFileSync(frameworkPath, path.join(outputPromptDir, `${framework}.md`));

  console.log(`Generated: ${outputDir}`);
}

main().catch((error: Error) => {
  console.error(`Error: ${error.message}`);
  process.exit(1);
});
