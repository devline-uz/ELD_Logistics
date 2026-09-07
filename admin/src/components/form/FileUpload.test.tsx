import { act, fireEvent, render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi, beforeEach, afterEach } from 'vitest';

import { FileUpload } from './FileUpload';

/** Sodda qo'lda XHR mocki — progress/load/error hodisalarini nazorat qilish uchun. */
class FakeXhr {
  static instances: FakeXhr[] = [];
  method = '';
  url = '';
  status = 0;
  requestHeaders: Record<string, string> = {};
  upload = {
    addEventListener: vi.fn((event: string, cb: (e: unknown) => void) => {
      if (event === 'progress') this._onProgress = cb;
    }),
  };
  private listeners: Record<string, ((e?: unknown) => void)[]> = {};
  private _onProgress?: (e: unknown) => void;

  constructor() {
    FakeXhr.instances.push(this);
  }

  open(method: string, url: string) {
    this.method = method;
    this.url = url;
  }

  setRequestHeader(name: string, value: string) {
    this.requestHeaders[name] = value;
  }

  addEventListener(event: string, cb: (e?: unknown) => void) {
    this.listeners[event] ??= [];
    this.listeners[event].push(cb);
  }

  send() {
    /* test drives completion manually via helpers below */
  }

  abort() {
    this.listeners.abort?.forEach((cb) => cb());
  }

  emitProgress(loaded: number, total: number) {
    this._onProgress?.({ lengthComputable: true, loaded, total });
  }

  emitLoad(status: number) {
    this.status = status;
    this.listeners.load?.forEach((cb) => cb());
  }

  emitError() {
    this.listeners.error?.forEach((cb) => cb());
  }
}

function makeFile(name: string, type: string, sizeBytes: number): File {
  const file = new File([new Uint8Array(sizeBytes)], name, { type });
  return file;
}

describe('FileUpload', () => {
  beforeEach(() => {
    FakeXhr.instances = [];
    vi.stubGlobal('XMLHttpRequest', FakeXhr);
  });

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it('rejects a file with a disallowed MIME type before presigning', async () => {
    const onPresign = vi.fn();
    const onUploaded = vi.fn();
    const onError = vi.fn();
    render(
      <FileUpload
        kind="dvir_photo"
        label="Defect photo"
        onPresign={onPresign}
        onUploaded={onUploaded}
        onError={onError}
      />,
    );

    const input = document.querySelector('input[type="file"]') as HTMLInputElement;
    const badFile = makeFile('doc.pdf', 'application/pdf', 100);
    // `userEvent.upload` enforces the `accept` attribute client-side and would
    // silently drop this file; drag-and-drop / "All files" pickers do not, so
    // `fireEvent` is used here to exercise our own MIME check as the real
    // safety net (fe-api §8: "klient tomonda MIME va kengaytma tekshiriladi").
    Object.defineProperty(input, 'files', { value: [badFile] });
    fireEvent.change(input);

    expect(onPresign).not.toHaveBeenCalled();
    expect(onError).toHaveBeenCalled();
    expect(await screen.findByRole('alert')).toBeInTheDocument();
  });

  it('rejects a file larger than the kind ceiling before presigning', async () => {
    const onPresign = vi.fn();
    render(
      <FileUpload kind="signature" label="Signature" onPresign={onPresign} onUploaded={vi.fn()} />,
    );

    const input = document.querySelector('input[type="file"]') as HTMLInputElement;
    const tooBig = makeFile('sig.png', 'image/png', 2 * 1024 * 1024);
    await userEvent.upload(input, tooBig);

    expect(onPresign).not.toHaveBeenCalled();
    expect(await screen.findByRole('alert')).toBeInTheDocument();
  });

  it('presigns, uploads via XHR with progress, and reports the uploaded key', async () => {
    const onPresign = vi.fn().mockResolvedValue({
      upload_url: 'https://storage.example/upload',
      method: 'PUT',
      key: 'companies/1/dvir_photo/abc.jpg',
      headers: { 'Content-Type': 'image/jpeg' },
      max_bytes: 5 * 1024 * 1024,
    });
    const onUploaded = vi.fn();

    render(
      <FileUpload
        kind="dvir_photo"
        label="Defect photo"
        onPresign={onPresign}
        onUploaded={onUploaded}
      />,
    );

    const input = document.querySelector('input[type="file"]') as HTMLInputElement;
    const file = makeFile('front.jpg', 'image/jpeg', 1024);
    await userEvent.upload(input, file);

    await waitFor(() =>
      expect(onPresign).toHaveBeenCalledWith({
        kind: 'dvir_photo',
        content_type: 'image/jpeg',
        size_bytes: 1024,
        filename: 'front.jpg',
      }),
    );

    await waitFor(() => expect(FakeXhr.instances).toHaveLength(1));
    const xhr = FakeXhr.instances[0]!;
    expect(xhr.url).toBe('https://storage.example/upload');

    act(() => xhr.emitProgress(512, 1024));
    expect(await screen.findByRole('progressbar')).toHaveAttribute('aria-valuenow', '50');

    await act(async () => {
      xhr.emitLoad(200);
      await Promise.resolve();
    });

    await waitFor(() =>
      expect(onUploaded).toHaveBeenCalledWith({
        key: 'companies/1/dvir_photo/abc.jpg',
        filename: 'front.jpg',
        size: 1024,
        contentType: 'image/jpeg',
      }),
    );
    expect(await screen.findByRole('status')).toHaveTextContent('front.jpg');
  });

  it('shows an error and offers retry when the upload fails', async () => {
    const onPresign = vi.fn().mockResolvedValue({
      upload_url: 'https://storage.example/upload',
      method: 'PUT',
      key: 'k',
      max_bytes: 5 * 1024 * 1024,
    });
    const onError = vi.fn();

    render(
      <FileUpload
        kind="dvir_photo"
        label="Defect photo"
        onPresign={onPresign}
        onUploaded={vi.fn()}
        onError={onError}
      />,
    );

    const input = document.querySelector('input[type="file"]') as HTMLInputElement;
    await userEvent.upload(input, makeFile('front.jpg', 'image/jpeg', 1024));

    await waitFor(() => expect(FakeXhr.instances).toHaveLength(1));
    await act(async () => {
      FakeXhr.instances[0]!.emitError();
      await Promise.resolve();
    });

    expect(await screen.findByRole('alert')).toBeInTheDocument();
    expect(onError).toHaveBeenCalled();
    expect(screen.getByRole('button', { name: /try again/i })).toBeInTheDocument();
  });

  it('cancels an in-flight upload via the Cancel button', async () => {
    const onPresign = vi.fn().mockResolvedValue({
      upload_url: 'https://storage.example/upload',
      method: 'PUT',
      key: 'k',
      max_bytes: 5 * 1024 * 1024,
    });

    render(
      <FileUpload
        kind="dvir_photo"
        label="Defect photo"
        onPresign={onPresign}
        onUploaded={vi.fn()}
      />,
    );

    const input = document.querySelector('input[type="file"]') as HTMLInputElement;
    await userEvent.upload(input, makeFile('front.jpg', 'image/jpeg', 1024));

    const cancelButton = await screen.findByRole('button', { name: /cancel/i });
    await userEvent.click(cancelButton);

    expect(await screen.findByRole('alert')).toHaveTextContent(/cancel/i);
  });
});
