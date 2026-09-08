import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { Card } from '@/components/ui/Card';

describe('Card', () => {
  it('renders title, actions, content and footer', () => {
    render(
      <Card
        title="Recent activity"
        actions={<button type="button">Export</button>}
        footer="Updated 2 min ago"
      >
        <p>Body content</p>
      </Card>,
    );

    expect(screen.getByRole('heading', { name: 'Recent activity' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Export' })).toBeInTheDocument();
    expect(screen.getByText('Body content')).toBeInTheDocument();
    expect(screen.getByText('Updated 2 min ago')).toBeInTheDocument();
  });

  it('renders without a header when no title or actions are given', () => {
    render(<Card>Just content</Card>);
    expect(screen.queryByRole('heading')).not.toBeInTheDocument();
    expect(screen.getByText('Just content')).toBeInTheDocument();
  });
});
