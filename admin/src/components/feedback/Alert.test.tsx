import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { Alert } from '@/components/feedback/Alert';

describe('Alert', () => {
  it('renders error variant as an assertive alert', () => {
    render(<Alert message="Invalid credentials" variant="error" />);
    const alert = screen.getByRole('alert');
    expect(alert).toHaveTextContent('Invalid credentials');
    expect(alert).toHaveAttribute('aria-live', 'assertive');
  });

  it('renders non-error variants as a polite status', () => {
    render(<Alert message="Check your email" variant="info" />);
    const status = screen.getByRole('status');
    expect(status).toHaveTextContent('Check your email');
    expect(status).toHaveAttribute('aria-live', 'polite');
  });

  it('defaults to the error variant', () => {
    render(<Alert message="Something failed" />);
    expect(screen.getByRole('alert')).toBeInTheDocument();
  });
});
