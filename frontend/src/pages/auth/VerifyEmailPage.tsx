import React from 'react';
import { useSelector } from 'react-redux';
import { RootState } from '../../store';

export const VerifyEmailPage: React.FC = () => {
  const { user } = useSelector((state: RootState) => state.auth);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div className="text-center">
          <div className="mx-auto h-12 w-12 flex items-center justify-center rounded-xl bg-yellow-100">
            <svg className="h-6 w-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.464 0L4.35 16.5c-.77.833.192 2.5 1.732 2.5z" />
            </svg>
          </div>
          <h2 className="mt-6 text-3xl font-extrabold text-gray-900">
            Verify your email
          </h2>
          <p className="mt-2 text-sm text-gray-600">
            We've sent a verification email to{' '}
            <span className="font-medium text-gray-900">{user?.email}</span>
          </p>
        </div>

        <div className="rounded-md bg-blue-50 p-4">
          <div className="flex">
            <div className="ml-3">
              <h3 className="text-sm font-medium text-blue-800">
                Please check your email
              </h3>
              <div className="mt-2 text-sm text-blue-700">
                <p>
                  Click the verification link in your email to activate your account.
                  If you don't see the email, check your spam folder.
                </p>
              </div>
            </div>
          </div>
        </div>

        <div className="text-center">
          <button
            className="text-sm text-blue-600 hover:text-blue-500 font-medium"
            onClick={() => {
              // TODO: Implement resend verification
              console.log('Resend verification email');
            }}
          >
            Resend verification email
          </button>
        </div>
      </div>
    </div>
  );
};