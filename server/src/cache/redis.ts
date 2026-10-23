import Redis from 'ioredis';

export const redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379', {
  lazyConnect: true, maxRetriesPerRequest: 1, retryStrategy: (n) => n > 1 ? null : Math.min(n * 250, 500),
});
let nextRedisProbe = 0;
let redisWarningShown = false;
redis.on('error', (error) => {
  if (!redisWarningShown) { console.warn('Redis unavailable; continuing without cache:', error.message); redisWarningShown = true; }
});
async function connectIfAvailable(): Promise<boolean> {
  if (redis.status === 'ready') return true;
  if (Date.now() < nextRedisProbe) return false;
  nextRedisProbe = Date.now() + 30000;
  try {
    if (redis.status === 'wait' || redis.status === 'end') await redis.connect();
    return String(redis.status) === 'ready';
  } catch { return false; }
}
export async function testRedisConnection(): Promise<void> {
  nextRedisProbe = Date.now() + 30000;
  try { if (redis.status === 'wait') await redis.connect(); await redis.ping(); nextRedisProbe = 0; }
  catch { console.warn('Redis is unavailable; API will continue without cache.'); }
}
export async function getCache<T>(key: string): Promise<T | null> {
  try { if (!await connectIfAvailable()) return null; const value = await redis.get(key); return value ? JSON.parse(value) as T : null; }
  catch { return null; }
}
export async function setCache(key: string, value: unknown, ttl: number): Promise<void> {
  try { if (await connectIfAvailable()) await redis.set(key, JSON.stringify(value), 'EX', ttl); } catch { /* Cache failures must not fail API requests. */ }
}
export async function deleteCacheByPattern(pattern: string): Promise<void> {
  try {
    if (!await connectIfAvailable()) return;
    let cursor = '0';
    do { const [next, keys] = await redis.scan(cursor, 'MATCH', pattern, 'COUNT', 100); cursor = next; if (keys.length) await redis.del(...keys); } while (cursor !== '0');
  } catch { /* Cache failures must not fail API requests. */ }
}
