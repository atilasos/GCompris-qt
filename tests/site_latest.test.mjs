// SPDX-FileCopyrightText: NONE
// SPDX-License-Identifier: CC0-1.0
import vm from 'node:vm';
import fs from 'node:fs';
import assert from 'node:assert/strict';
import test from 'node:test';

const script = fs.readFileSync(new URL('../site/latest.js', import.meta.url), 'utf8');
const metadata = {
  date: '2026-10-18', run: '12345', source: 'a'.repeat(40),
  sha256: 'b'.repeat(64), bytes: 100, activities: 211,
  url: 'https://github.com/atilasos/GCompris-qt/releases/download/windows-12345/GCompris-PT-PT-Windows-x64-candidate.exe',
};
const release = {
  tag_name: 'windows-12345', draft: false, published_at: '2026-10-18',
  body: '<!-- gcompris-release: ' + JSON.stringify(metadata) + ' -->',
  assets: [
    {
      name: 'GCompris-PT-PT-Windows-x64-candidate.exe', size: 100,
      digest: 'sha256:' + metadata.sha256, browser_download_url: metadata.url,
    },
    {
      name: 'SHA256SUMS.txt',
      browser_download_url: 'https://github.com/atilasos/GCompris-qt/releases/download/windows-12345/SHA256SUMS.txt',
    },
  ],
};

async function downloadSelected(releases, ok = true) {
  const nodes = new Map();
  const context = {
    fetch: async url => ({
      ok,
      json: async () => url === 'release.json'
        ? {date: '2026-10-16', run: 'old', activities: 211}
        : releases,
    }),
    AbortSignal, Date, Number, JSON,
    document: {
      querySelector: selector => {
        if (!nodes.has(selector)) nodes.set(selector, {href: 'original', textContent: ''});
        return nodes.get(selector);
      },
    },
  };
  await vm.runInNewContext(script, context);
  return nodes.get('.download-button')?.href;
}

test('selects a newer installer with matching GitHub asset identity', async () => {
  assert.equal(await downloadSelected([release]), metadata.url);
});

test('preserves the static download when the asset digest differs', async () => {
  const tampered = structuredClone(release);
  tampered.assets[0].digest = 'sha256:' + 'c'.repeat(64);
  assert.equal(await downloadSelected([tampered]), undefined);
});

test('preserves the static download when the API fails', async () => {
  assert.equal(await downloadSelected([], false), undefined);
});

test('does not select a package with fewer activities than the pinned build', async () => {
  const fewer = structuredClone(release);
  fewer.body = fewer.body.replace('"activities":211', '"activities":203');
  assert.equal(await downloadSelected([fewer]), undefined);
});
