import React from 'react';
import { screen } from '@testing-library/react';
import { renderWithProviders, mockAuthenticatedState, mockUnauthenticatedState } from '../../utils/test-utils';
import { ProtectedRoute } from './ProtectedRoute';

const TestComponent = () => <div>Protected Content</div>;

describe('ProtectedRoute', () => {
  it('renders children when user is authenticated', () => {
    renderWithProviders(
      <ProtectedRoute>
        <TestComponent />
      </ProtectedRoute>,
      {
        preloadedState: mockAuthenticatedState,
        route: '/dashboard',
      }
    );

    expect(screen.getByText('Protected Content')).toBeInTheDocument();
  });

  it('redirects to login when user is not authenticated', () => {
    renderWithProviders(
      <ProtectedRoute>
        <TestComponent />
      </ProtectedRoute>,
      {
        preloadedState: mockUnauthenticatedState,
        route: '/dashboard',
      }
    );

    // Should redirect, so protected content should not be visible
    expect(screen.queryByText('Protected Content')).not.toBeInTheDocument();
    
    // Check if we're on the login page (this would require mocking useNavigate)
    expect(window.location.pathname).toBe('/login');
  });

  it('redirects to email verification when user is unverified and email verification is required', () => {
    const unverifiedUserState = {
      ...mockAuthenticatedState,
      auth: {
        ...mockAuthenticatedState.auth,
        user: {
          ...mockAuthenticatedState.auth.user!,
          emailVerified: false,
        },
      },
    };

    renderWithProviders(
      <ProtectedRoute requireEmailVerification>
        <TestComponent />
      </ProtectedRoute>,
      {
        preloadedState: unverifiedUserState,
        route: '/dashboard',
      }
    );

    expect(screen.queryByText('Protected Content')).not.toBeInTheDocument();
    expect(window.location.pathname).toBe('/verify-email');
  });

  it('allows access when user has required role', () => {
    renderWithProviders(
      <ProtectedRoute requiredRoles={['admin']}>
        <TestComponent />
      </ProtectedRoute>,
      {
        preloadedState: mockAuthenticatedState, // User is admin
        route: '/admin',
      }
    );

    expect(screen.getByText('Protected Content')).toBeInTheDocument();
  });

  it('redirects to unauthorized when user lacks required role', () => {
    const memberUserState = {
      ...mockAuthenticatedState,
      auth: {
        ...mockAuthenticatedState.auth,
        user: {
          ...mockAuthenticatedState.auth.user!,
          role: 'member',
        },
      },
    };

    renderWithProviders(
      <ProtectedRoute requiredRoles={['admin', 'owner']}>
        <TestComponent />
      </ProtectedRoute>,
      {
        preloadedState: memberUserState,
        route: '/admin',
      }
    );

    expect(screen.queryByText('Protected Content')).not.toBeInTheDocument();
    expect(window.location.pathname).toBe('/unauthorized');
  });

  it('allows access for multiple required roles', () => {
    const ownerUserState = {
      ...mockAuthenticatedState,
      auth: {
        ...mockAuthenticatedState.auth,
        user: {
          ...mockAuthenticatedState.auth.user!,
          role: 'owner',
        },
      },
    };

    renderWithProviders(
      <ProtectedRoute requiredRoles={['admin', 'owner']}>
        <TestComponent />
      </ProtectedRoute>,
      {
        preloadedState: ownerUserState,
        route: '/admin',
      }
    );

    expect(screen.getByText('Protected Content')).toBeInTheDocument();
  });
});