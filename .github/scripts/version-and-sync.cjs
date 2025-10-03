const { execSync } = require('child_process');
const fs = require('fs');

function run(cmd) {
  execSync(cmd, { stdio: 'inherit', env: process.env });
}

// 1) Version packages via Changesets
run('npx -y @changesets/cli@^2.27.9 changeset version');

// 2) Sync canonical VERSION from package.json
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
const next = (pkg.version || '').trim();
if (!next) {
  console.error('No version found in package.json');
  process.exit(1);
}
fs.writeFileSync('VERSION', `${next}\n`, 'utf8');

// 3) Stage VERSION so the action commits it
run('git add VERSION');


