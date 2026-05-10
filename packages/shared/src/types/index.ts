// Domain types — populated as models are defined.
// Reference: 09_Ascend_DatabaseSchema.md

export type Pagination = {
  cursor?: string;
  limit: number;
};

export type PaginatedResult<T> = {
  data: T[];
  nextCursor: string | null;
};
