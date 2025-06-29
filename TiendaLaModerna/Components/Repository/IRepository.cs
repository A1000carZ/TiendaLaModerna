namespace TiendaLaModerna.Components.Repository
{
    public interface Repository<T, TId>
    {
        Task<T> CreateAsync(T entity);

        Task<T> ReadAsync(TId id);

        Task<T> UpdateAsync(T entity);

        Task DeleteAsync(TId id);

        Task<IEnumerable<T>> GetAllAsync();

        Task<bool> Exists(TId id);
    }
}
