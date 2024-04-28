export interface Profile {
  id: string;
  updated_at: string;
  username: string;
  full_name?: string;
  avatar_url?: string;
  website?: string;
}

export interface NewsProvider {
  id: number;
  created_at: string;
  created_by: string;
  is_activated: boolean;
  is_google_news: boolean;
}

export interface NewsSettings {
    id: number,
    created_at: string;
    created_by: string;
    interests: any,
    wants_interests: boolean,
    countries: any,
    wants_countries: boolean,
    cities: any,
    wants_cities: boolean,
    user_prompt: string,
    providers_id: any
}

export interface News {
  title: string;
  description: string;
  content: string;
  publishedAt: Date;
  url: string;
  source: {
    name: string;
    url: string;
  };
}

interface GNewsProvider {
  type: "gnews";
}

interface RSSProvider {
  type: "rss";
  url: string;
}

/**
 * Describe a provider where news can be fetched.
 * They can be distinguished by their `type` property.
 */
export type Provider = GNewsProvider | RSSProvider;
