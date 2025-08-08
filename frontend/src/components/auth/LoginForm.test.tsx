import React from 'react';
import { screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { renderWithProviders, mockUnauthenticatedState } from '../../utils/test-utils';
import { LoginPage } from '../../pages/auth/LoginPage';
import { authAPI } from '../../services/authAPI';

// Mock the authAPI
jest.mock('../../services/authAPI');
const mockedAuthAPI = authAPI as jest.Mocked<typeof authAPI>;

// Mock react-router-dom navigate
const mockNavigate = jest.fn();
jest.mock('react-router-dom', () => ({
  ...jest.requireActual('react-router-dom'),
  useNavigate: () => mockNavigate,
  useLocation: () => ({ state: null }),
}));

describe('LoginPage', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders login form correctly', () => {
    renderWithProviders(<LoginPage />, {
      preloadedState: mockUnauthenticatedState,
    });

    expect(screen.getByText('Sign in to your account')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Email address')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Password')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /sign in/i })).toBeInTheDocument();
    expect(screen.getByText('Forgot your password?')).toBeInTheDocument();
    expect(screen.getByText('create a new account')).toBeInTheDocument();
  });

  it('handles successful login', async () => {
    const user = userEvent.setup();
    const mockResponse = {
      data: {
        user: {
          id: '123',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          role: 'admin',
          status: 'active',
          emailVerified: true,
          account: {
            id: '456',
            name: 'Test Company',
            status: 'active',
          },
        },
        access_token: 'mock-access-token',
        refresh_token: 'mock-refresh-token',
      },
    };

    mockedAuthAPI.login.mockResolvedValueOnce(mockResponse);

    renderWithProviders(<LoginPage />, {
      preloadedState: mockUnauthenticatedState,
    });

    // Fill in the form
    await user.type(screen.getByPlaceholderText('Email address'), 'test@example.com');
    await user.type(screen.getByPlaceholderText('Password'), 'password123');

    // Submit the form
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    await waitFor(() => {
      expect(mockedAuthAPI.login).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
      });
    });
  });

  it('handles login error', async () => {
    const user = userEvent.setup();
    const mockError = {
      response: {
        data: {
          error: 'Invalid email or password',
        },
      },
    };

    mockedAuthAPI.login.mockRejectedValueOnce(mockError);

    renderWithProviders(<LoginPage />, {
      preloadedState: mockUnauthenticatedState,
    });

    // Fill in the form
    await user.type(screen.getByPlaceholderText('Email address'), 'wrong@example.com');
    await user.type(screen.getByPlaceholderText('Password'), 'wrongpassword');

    // Submit the form
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    await waitFor(() => {
      expect(screen.getByText('Invalid email or password')).toBeInTheDocument();
    });
  });

  it('validates required fields', async () => {
    const user = userEvent.setup();

    renderWithProviders(<LoginPage />, {
      preloadedState: mockUnauthenticatedState,
    });

    // Try to submit without filling fields
    const submitButton = screen.getByRole('button', { name: /sign in/i });
    await user.click(submitButton);

    // HTML5 validation should prevent form submission
    const emailField = screen.getByPlaceholderText('Email address');
    const passwordField = screen.getByPlaceholderText('Password');

    expect(emailField).toBeInvalid();
    expect(passwordField).toBeInvalid();
  });

  it('shows loading state during login', async () => {
    const user = userEvent.setup();
    let resolvePromise: (value: any) => void;
    const pendingPromise = new Promise((resolve) => {
      resolvePromise = resolve;
    });

    mockedAuthAPI.login.mockReturnValueOnce(pendingPromise);

    renderWithProviders(<LoginPage />, {
      preloadedState: mockUnauthenticatedState,
    });

    // Fill in the form
    await user.type(screen.getByPlaceholderText('Email address'), 'test@example.com');
    await user.type(screen.getByPlaceholderText('Password'), 'password123');

    // Submit the form
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    // Check loading state
    expect(screen.getByText('Signing in...')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /signing in/i })).toBeDisabled();

    // Resolve the promise
    resolvePromise!({
      data: {
        user: {},
        access_token: 'token',
        refresh_token: 'refresh',
      },
    });
  });

  it('clears error when user starts typing', async () => {
    const user = userEvent.setup();

    renderWithProviders(<LoginPage />, {
      preloadedState: {
        ...mockUnauthenticatedState,
        auth: {
          ...mockUnauthenticatedState.auth,
          error: 'Previous error',
        },
      },
    });

    // Error should be displayed initially
    expect(screen.getByText('Previous error')).toBeInTheDocument();

    // Start typing in email field
    await user.type(screen.getByPlaceholderText('Email address'), 't');

    // Error should be cleared (this would require the component to dispatch clearError)
    await waitFor(() => {
      expect(screen.queryByText('Previous error')).not.toBeInTheDocument();
    });
  });
});