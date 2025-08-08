import { configureStore } from '@reduxjs/toolkit';
import authReducer, {
  login,
  logout,
  clearError,
  clearAuth,
  register,
  getCurrentUser,
  refreshAccessToken,
} from './authSlice';
import { authAPI } from '../../services/authAPI';

// Mock the auth API
jest.mock('../../services/authAPI');
const mockedAuthAPI = authAPI as jest.Mocked<typeof authAPI>;

// Mock localStorage
const localStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
};
(global as any).localStorage = localStorageMock;

describe('authSlice', () => {
  let store: ReturnType<typeof configureStore>;

  beforeEach(() => {
    store = configureStore({
      reducer: {
        auth: authReducer,
      },
    });
    jest.clearAllMocks();
    localStorageMock.getItem.mockReturnValue(null);
  });

  describe('initial state', () => {
    it('should have correct initial state', () => {
      const state = store.getState().auth;
      expect(state).toEqual({
        user: null,
        accessToken: null,
        refreshToken: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,
      });
    });

    it('should load tokens from localStorage on init', () => {
      localStorageMock.getItem.mockImplementation((key) => {
        if (key === 'accessToken') return 'stored-access-token';
        if (key === 'refreshToken') return 'stored-refresh-token';
        return null;
      });

      // Create a new store to trigger initialization
      const storeWithTokens = configureStore({
        reducer: {
          auth: authReducer,
        },
      });

      const state = storeWithTokens.getState().auth;
      expect(state.accessToken).toBe('stored-access-token');
      expect(state.refreshToken).toBe('stored-refresh-token');
    });
  });

  describe('reducers', () => {
    it('should clear error', () => {
      // First set an error
      store.dispatch({
        type: 'auth/login/rejected',
        error: { message: 'Login failed' },
      });

      expect(store.getState().auth.error).toBe('Login failed');

      // Then clear it
      store.dispatch(clearError());
      expect(store.getState().auth.error).toBeNull();
    });

    it('should clear auth', () => {
      // First set some auth state
      store.dispatch({
        type: 'auth/login/fulfilled',
        payload: {
          user: { id: '1', email: 'test@example.com' },
          access_token: 'token',
          refresh_token: 'refresh',
        },
      });

      expect(store.getState().auth.isAuthenticated).toBe(true);

      // Then clear it
      store.dispatch(clearAuth());
      const state = store.getState().auth;
      expect(state.user).toBeNull();
      expect(state.accessToken).toBeNull();
      expect(state.refreshToken).toBeNull();
      expect(state.isAuthenticated).toBe(false);
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('accessToken');
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('refreshToken');
    });
  });

  describe('login async thunk', () => {
    const mockLoginResponse = {
      data: {
        user: {
          id: '1',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          role: 'admin',
          status: 'active',
          emailVerified: true,
          account: {
            id: '2',
            name: 'Test Company',
            status: 'active',
          },
        },
        access_token: 'mock-access-token',
        refresh_token: 'mock-refresh-token',
      },
    };

    it('should handle successful login', async () => {
      mockedAuthAPI.login.mockResolvedValueOnce(mockLoginResponse);

      const credentials = { email: 'test@example.com', password: 'password' };
      await store.dispatch(login(credentials));

      const state = store.getState().auth;
      expect(state.isLoading).toBe(false);
      expect(state.isAuthenticated).toBe(true);
      expect(state.user).toEqual(mockLoginResponse.data.user);
      expect(state.accessToken).toBe('mock-access-token');
      expect(state.refreshToken).toBe('mock-refresh-token');
      expect(state.error).toBeNull();

      expect(localStorageMock.setItem).toHaveBeenCalledWith('accessToken', 'mock-access-token');
      expect(localStorageMock.setItem).toHaveBeenCalledWith('refreshToken', 'mock-refresh-token');
    });

    it('should handle login failure', async () => {
      const mockError = new Error('Login failed');
      mockedAuthAPI.login.mockRejectedValueOnce(mockError);

      const credentials = { email: 'test@example.com', password: 'wrong' };
      await store.dispatch(login(credentials));

      const state = store.getState().auth;
      expect(state.isLoading).toBe(false);
      expect(state.isAuthenticated).toBe(false);
      expect(state.user).toBeNull();
      expect(state.error).toBe('Login failed');
    });

    it('should set loading state during login', async () => {
      let resolvePromise: (value: any) => void;
      const pendingPromise = new Promise((resolve) => {
        resolvePromise = resolve;
      });
      
      mockedAuthAPI.login.mockReturnValueOnce(pendingPromise);

      const loginPromise = store.dispatch(login({
        email: 'test@example.com',
        password: 'password',
      }));

      // Check loading state
      expect(store.getState().auth.isLoading).toBe(true);
      expect(store.getState().auth.error).toBeNull();

      // Resolve the promise
      resolvePromise!(mockLoginResponse);
      await loginPromise;

      expect(store.getState().auth.isLoading).toBe(false);
    });
  });

  describe('register async thunk', () => {
    const mockRegisterResponse = {
      data: {
        user: {
          id: '1',
          email: 'newuser@example.com',
          firstName: 'Jane',
          lastName: 'Smith',
          role: 'owner',
          status: 'active',
          emailVerified: false,
          account: {
            id: '2',
            name: 'New Company',
            status: 'active',
          },
        },
        access_token: 'new-access-token',
        refresh_token: 'new-refresh-token',
      },
    };

    it('should handle successful registration', async () => {
      mockedAuthAPI.register.mockResolvedValueOnce(mockRegisterResponse);

      const userData = {
        email: 'newuser@example.com',
        password: 'password123',
        firstName: 'Jane',
        lastName: 'Smith',
        accountName: 'New Company',
      };

      await store.dispatch(register(userData));

      const state = store.getState().auth;
      expect(state.isLoading).toBe(false);
      expect(state.isAuthenticated).toBe(true);
      expect(state.user).toEqual(mockRegisterResponse.data.user);
      expect(state.accessToken).toBe('new-access-token');
      expect(state.refreshToken).toBe('new-refresh-token');
    });

    it('should handle registration failure', async () => {
      const mockError = new Error('Registration failed');
      mockedAuthAPI.register.mockRejectedValueOnce(mockError);

      const userData = {
        email: 'newuser@example.com',
        password: 'password123',
        firstName: 'Jane',
        lastName: 'Smith',
        accountName: 'New Company',
      };

      await store.dispatch(register(userData));

      const state = store.getState().auth;
      expect(state.isLoading).toBe(false);
      expect(state.isAuthenticated).toBe(false);
      expect(state.error).toBe('Registration failed');
    });
  });

  describe('logout async thunk', () => {
    it('should handle successful logout', async () => {
      // First login to set auth state
      store.dispatch({
        type: 'auth/login/fulfilled',
        payload: {
          user: { id: '1', email: 'test@example.com' },
          access_token: 'token',
          refresh_token: 'refresh',
        },
      });

      mockedAuthAPI.logout.mockResolvedValueOnce({ data: {} });

      await store.dispatch(logout());

      const state = store.getState().auth;
      expect(state.user).toBeNull();
      expect(state.accessToken).toBeNull();
      expect(state.refreshToken).toBeNull();
      expect(state.isAuthenticated).toBe(false);

      expect(localStorageMock.removeItem).toHaveBeenCalledWith('accessToken');
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('refreshToken');
    });
  });

  describe('getCurrentUser async thunk', () => {
    it('should handle successful user fetch', async () => {
      const mockUserResponse = {
        data: {
          user: {
            id: '1',
            email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            role: 'admin',
            status: 'active',
            emailVerified: true,
            account: {
              id: '2',
              name: 'Test Company',
              status: 'active',
            },
          },
        },
      };

      mockedAuthAPI.getCurrentUser.mockResolvedValueOnce(mockUserResponse);

      await store.dispatch(getCurrentUser());

      const state = store.getState().auth;
      expect(state.user).toEqual(mockUserResponse.data.user);
      expect(state.isAuthenticated).toBe(true);
    });

    it('should handle user fetch failure', async () => {
      mockedAuthAPI.getCurrentUser.mockRejectedValueOnce(new Error('Unauthorized'));

      await store.dispatch(getCurrentUser());

      const state = store.getState().auth;
      expect(state.user).toBeNull();
      expect(state.isAuthenticated).toBe(false);
    });
  });

  describe('refreshAccessToken async thunk', () => {
    it('should handle successful token refresh', async () => {
      const mockRefreshResponse = {
        data: {
          access_token: 'new-access-token',
          refresh_token: 'new-refresh-token',
        },
      };

      mockedAuthAPI.refreshToken.mockResolvedValueOnce(mockRefreshResponse);

      // Set initial state with refresh token
      store.dispatch({
        type: 'auth/login/fulfilled',
        payload: {
          user: { id: '1' },
          access_token: 'old-token',
          refresh_token: 'old-refresh',
        },
      });

      await store.dispatch(refreshAccessToken());

      const state = store.getState().auth;
      expect(state.accessToken).toBe('new-access-token');
      expect(state.refreshToken).toBe('new-refresh-token');

      expect(localStorageMock.setItem).toHaveBeenCalledWith('accessToken', 'new-access-token');
      expect(localStorageMock.setItem).toHaveBeenCalledWith('refreshToken', 'new-refresh-token');
    });

    it('should clear auth on refresh failure', async () => {
      mockedAuthAPI.refreshToken.mockRejectedValueOnce(new Error('Refresh failed'));

      // Set initial state with refresh token
      store.dispatch({
        type: 'auth/login/fulfilled',
        payload: {
          user: { id: '1' },
          access_token: 'old-token',
          refresh_token: 'old-refresh',
        },
      });

      await store.dispatch(refreshAccessToken());

      const state = store.getState().auth;
      expect(state.user).toBeNull();
      expect(state.accessToken).toBeNull();
      expect(state.refreshToken).toBeNull();
      expect(state.isAuthenticated).toBe(false);
    });
  });
});