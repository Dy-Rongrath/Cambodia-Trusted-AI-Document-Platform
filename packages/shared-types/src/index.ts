export interface HealthResponse {
  status: 'ok';
  service: string;
}

export type DependencyHealthStatus = 'ok' | 'unavailable';

export interface ReadinessResponse {
  status: 'ok' | 'unavailable';
  service: string;
  dependencies: Record<string, DependencyHealthStatus>;
}
