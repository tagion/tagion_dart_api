abstract interface class IStorable<T, E> {
  E toEntity();
  T fromEntity(E entity);
}
