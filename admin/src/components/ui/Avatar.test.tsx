import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';

import { Avatar } from '@/components/ui/Avatar';

describe('Avatar', () => {
  it('falls back to initials when no image is given', () => {
    render(<Avatar name="John Smith" />);
    const avatar = screen.getByRole('img', { name: 'John Smith' });
    expect(avatar).toHaveTextContent('JS');
  });

  it('uses a single-word name for a two-letter fallback', () => {
    render(<Avatar name="Admin" />);
    expect(screen.getByRole('img', { name: 'Admin' })).toHaveTextContent('AD');
  });

  it('renders an image with alt text when src is provided', () => {
    render(<Avatar name="Jane Doe" src="/avatars/jane.png" />);
    const image = screen.getByRole('img', { name: 'Jane Doe' });
    expect(image.tagName).toBe('IMG');
    expect(image).toHaveAttribute('src', '/avatars/jane.png');
  });

  it('renders no initials when given a blank name', () => {
    render(<Avatar name="   " />);
    const avatar = screen.getByRole('img');
    expect(avatar).toHaveTextContent('');
  });
});
