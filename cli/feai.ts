const fs = require("node:fs");
const path = require("node:path");
const readline = require("node:readline");

type Framework = "react" | "vue";

const VALID_FRAMEWORKS = new Set<Framework>(["react", "vue"]);

function isFramework(value: string): value is Framework {
  return VALID_FRAMEWORKS.has(value as Framework);
}

function printHelp(): void {
  console.log(`\nfeai - 生成前端项目系统提示词\n\n用法:\n  feai [--framework <react|vue>]\n  feai [react|vue]\n\n参数:\n  -f, --framework   指定框架并跳过交互\n  -h, --help        显示帮助\n`);
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
        throw new Error("缺少 --framework 参数值");
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

    throw new Error(`未知参数: ${arg}`);
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
    const answer = await askQuestion("请选择框架 (react/vue): ");
    const value = answer.trim().toLowerCase();
    if (isFramework(value)) {
      return value;
    }
    console.log("输入无效，请输入 react 或 vue。");
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
    throw new Error(`${label} 不存在: ${filePath}`);
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
      throw new Error(`不支持的框架: ${framework}`);
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
      `assets 不存在: ${distAssetsDir}. 请先执行构建命令生成 dist assets。`
    );
  }

  const assetsBase = isProduction ? distAssetsDir : __dirname;
  const templatePath = path.join(assetsBase, "template", "AGENT.md");
  const promptDir = path.join(assetsBase, "system-prompt");

  ensureFileExists(templatePath, "模板文件");
  ensureFileExists(promptDir, "system-prompt 目录");

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
  ensureFileExists(tailwindPath, "tailwind 文件");
  ensureFileExists(precisionPath, "number-calculation 文件");
  ensureFileExists(typescriptPath, "typescript 文件");
  ensureFileExists(frameworkPath, "框架文件");

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

  console.log(`已生成: ${outputDir}`);
}

main().catch((error: Error) => {
  console.error(`错误: ${error.message}`);
  process.exit(1);
});
