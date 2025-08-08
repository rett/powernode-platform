# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **Powernode** built with:
- **Backend**: Ruby on Rails 8 API-only application (located in `./server` directory)
- **Frontend**: ReactJS with TypeScript (located in `./frontend` directory)
- **Database**: PostgreSQL
- **Payments**: Stripe (primary), PayPal (secondary)
- **Background Jobs**: Sidekiq (standalone agent with API-only connectivity)
- **Testing**: RSpec (backend), Jest/Testing Library/Cypress (frontend)

The platform handles subscription lifecycle management, automated billing, payment processing, proration calculations, dunning management, and comprehensive analytics.

## Architecture Overview

### Backend Structure (Rails 8 API)
- **Models**: Account, User, Role, Permission, Invitation, AccountDelegation, Subscription, Plan, Invoice, Payment, AuditLog with complex associations
  - Users are associated with an Account (accounts may have multiple users)
  - Role-based access control with Users having Roles and Permissions
  - Subscriptions are associated with a Plan
  - Plans have configurable default roles
  - Plans include features and limits stored as hash
  - Default roles from plan are assigned to user on account creation
  - First created user becomes account owner
  - Invitations for new user invitees
  - Account Delegation support to allow existing users from different accounts
  - State machine functionality for subscription and payment states
  - Audit logging for all model changes and user actions
- **Primary Keys**: Use application-generated UUIDv7 for all primary keys
- **Authentication**: JWT authentication for API access
- **Services**: Payment processing, billing calculations, dunning management
- **Jobs**: Automated renewals, payment retries, notification sending
- **Controllers**: RESTful API endpoints with proper serialization
- **Webhooks**: Payment gateway event handling (Stripe, PayPal)

### Frontend Structure (React + TypeScript)
- **Pages**: Customer dashboard, admin panel, billing management, application settings, user management, account management, subscription management, invitations management, delegations management, payment processor management
- **Components**: Reusable UI components with accessibility
- **Store**: Redux/Context for state management
- **Services**: API integration and data fetching
- **Application Settings**: All application settings manageable from within the frontend

### Key Business Logic Areas
- **Subscription Lifecycle**: Creation, upgrades/downgrades, pausing, cancellation
- **Billing Engine**: Automated renewals, proration calculations, invoice generation
- **Payment Processing**: Gateway integrations, retry logic, webhook handling
- **Dunning Management**: Failed payment recovery, account suspension
- **Analytics**: MRR/ARR calculations, churn analysis, customer lifetime value

## Development Workflow

### Project Status Tracking
- Main task tracking should be maintained in a TODO.md file with development tasks
- Tasks use status indicators: `[ ]` PENDING, `[🔄]` IN_PROGRESS, `[✅]` COMPLETED, `[❌]` BLOCKED, `[⚠️]` NEEDS_REVIEW
- Always update task status when working on related features

### Development Commands
Since the project is in early stages with no existing Rails/React setup:
- **Rails Setup**: `cd server && rails new . --api --database=postgresql` (when creating backend in ./server directory)
- **React Setup**: `npx create-react-app frontend --template typescript` (when creating frontend in ./frontend directory)
- **Database**: Standard Rails commands from server directory (`cd server && rails db:create`, `rails db:migrate`, `rails db:seed`)
- **Testing**: `cd server && rspec` for backend, `cd frontend && npm test` for frontend when setup
- **Background Jobs**: Standalone agent approach - see Background Jobs Architecture section below

### Multi-Agent Coordination
The project uses a sophisticated agent-based development approach defined in `claude-swarm.yml`:
- **Backend Agents**: Rails architect, data modeler, payment specialist, billing engine developer
- **Frontend Agents**: React architect, UI developer, dashboard specialist, admin panel developer
- **Quality Agents**: Backend/frontend test engineers
- **Infrastructure Agents**: DevOps engineer, security specialist, performance optimizer

## Key Implementation Patterns

### Payment Integration
- Use service objects for payment gateway interactions
- Implement comprehensive webhook handling for payment events
- Store payment methods securely with PCI compliance considerations
- Handle payment retries with exponential backoff

### Subscription Management
- Model subscription states as state machines
- Implement proration calculations for mid-cycle changes
- Use background jobs for automated renewal processing
- Track subscription history for audit purposes

### Security Considerations
- JWT authentication for API access
- Rate limiting on all endpoints
- PCI DSS compliance for payment data
- Proper input validation and sanitization
- Environment-specific configuration management

### Background Jobs Architecture
- **Standalone Agent**: Background jobs run as a separate agent/service with no direct database connectivity
- **API-Only Communication**: All data access must go through the Rails API backend via HTTP requests
- **Rails Version**: Background job agent may use Rails 4.2 for sidekiq-web support and compatibility
- **Job Processing**: Sidekiq workers make API calls to the main Rails 8 backend for all data operations
- **Authentication**: Background job API calls use service-to-service authentication tokens
- **Scalability**: This architecture allows independent scaling of job processing and API backend

### Testing Strategy
- Comprehensive model tests with FactoryBot
- API endpoint testing with proper fixtures
- Payment processing tests using VCR or stubs
- Frontend component testing with Testing Library
- E2E tests for critical user flows

## Development Phases

The project follows a structured 6-phase approach:
1. **Backend Foundation** - Rails API setup, authentication, core models
2. **Payment Integration** - Gateway integrations, billing logic, webhooks
3. **Analytics & Reporting** - Business intelligence, KPI calculations
4. **Frontend Development** - React app, customer/admin interfaces
5. **Quality Assurance** - Comprehensive testing suite
6. **DevOps & Production** - CI/CD, monitoring, performance optimization

## Important Notes

- This is a greenfield project - no existing codebase yet
- Prioritize security and PCI compliance from the start
- Focus on scalable architecture for subscription growth
- Implement comprehensive error handling and logging
- Plan for multi-tenant capabilities if needed
- Consider regulatory compliance (tax calculations, reporting)

## Current Project Status

This is a greenfield subscription management platform with comprehensive planning completed:
- Multi-agent development approach defined in `claude-swarm.yml` 
- 17 specialized agents for different aspects of development
- Structured 6-phase development approach planned
- No code implementation has begun yet
