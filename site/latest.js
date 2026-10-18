// SPDX-FileCopyrightText: NONE
// SPDX-License-Identifier: CC0-1.0
// Keep the checked, static download as fallback if GitHub is unavailable.
(async () => {
  try {
    const response = await fetch('https://api.github.com/repos/atilasos/GCompris-qt/releases?per_page=20', {signal: AbortSignal.timeout(6000)});
    if (!response.ok) return;
    const releases = await response.json();
    const pinned = await fetch('release.json').then(r => r.json());
    const candidates = releases.filter(r => !r.draft && /^windows-\d+$/.test(r.tag_name)).sort((a,b) => Date.parse(b.published_at) - Date.parse(a.published_at));
    for (const release of candidates) {
      const match = (release.body || '').match(/<!-- gcompris-release: (.+) -->/);
      if (!match) continue;
      const metadata = JSON.parse(match[1]);
      const asset = release.assets.find(a => a.name === 'GCompris-PT-PT-Windows-x64-candidate.exe');
      const checksums = release.assets.find(a => a.name === 'SHA256SUMS.txt');
      if (!asset || !checksums || metadata.run !== release.tag_name.slice(8) ||
          !/^[a-f0-9]{64}$/.test(metadata.sha256) || !/^[a-f0-9]{40}$/.test(metadata.source) ||
          metadata.url !== asset.browser_download_url || metadata.bytes !== asset.size ||
          asset.digest !== 'sha256:' + metadata.sha256 ||
          !Number.isInteger(metadata.activities) || metadata.activities < (pinned.activities || 203) ||
          Date.parse(metadata.date) < Date.parse(pinned.date)) continue;
      if (metadata.run === pinned.run) return;
      document.querySelector('.download-button').href = metadata.url;
      document.querySelector('#download-description').textContent = `O candidato de teste mais recente inclui ${metadata.activities} atividades e os recursos para jogar sem Internet.`;
      const date = new Date(metadata.date + 'T12:00:00Z').toLocaleDateString('pt-PT', {timeZone:'UTC'});
      document.querySelector('#download-meta').textContent = `Windows x64 · ${(metadata.bytes / 1e6).toLocaleString('pt-PT', {maximumFractionDigits:1})} MB · ${date}`;
      document.querySelector('#download-availability').textContent = 'Instalador alojado no GitHub, disponível mesmo com o nosso computador desligado.';
      document.querySelector('#download-caveat').textContent = 'Este pacote corresponde ao código identificado abaixo. As notas do changelog registam o estado de cada alteração na data da publicação da página.';
      document.querySelector('.run-link').href = `https://github.com/atilasos/GCompris-qt/actions/runs/${metadata.run}`;
      document.querySelector('.hash').textContent = metadata.sha256;
      document.querySelector('.source-link').textContent = metadata.source.slice(0,10);
      document.querySelector('.source-link').href = `https://github.com/atilasos/GCompris-qt/commit/${metadata.source}`;
      document.querySelector('#release-run').textContent = metadata.run;
      document.querySelector('.checksum-link').href = checksums.browser_download_url;
      document.querySelector('.command').textContent = 'Get-FileHash .\\GCompris-PT-PT-Windows-x64-candidate.exe -Algorithm SHA256';
      return;
    }
  } catch {
    // The pre-rendered, verified installer remains fully usable.
  }
})();
